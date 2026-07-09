/**
 * Publishes Platform Events for Account and Contact updates driven by
 * Custom Metadata Type (CMT) field mappings.
 *
 * Account path:
 *   - Success: publishes sfdc_account_updatedSuccess__e with AcctCaseSafeID__c,
 *              uLab_Acct_Number__c, and Updated_Fields__c (JSON delta payload).
 *   - Failure: for each failed SaveResult, publishes sfdc_account_updatedFailed__e
 *              with the same header fields plus Status_Code__c, Error_Code__c,
 *              and Error_Message__c from the Database.Error.
 *
 * Contact path:
 *   - Success: publishes sfdc_user_updatedSuccess__e with ContactCaseSafeID__c,
 *              Portal_User_ID__c, and Updated_Fields__c (JSON delta payload).
 *   - Failure: for each failed SaveResult, publishes sfdc_user_updatedFailed__e
 *              with the same header fields plus Status_Code__c, Error_Code__c,
 *              and Error_Message__c from the Database.Error.
 *
 * Core algorithm per record:
 *   1. Load active CMT mappings from FieldMappingSelectorCache (0 SOQL).
 *   2. Build a PayloadResult using Salesforce_Field__c as the key:
 *      - Header fields (Is_Header_Field__c = true): always added.
 *      - Non-header fields: added only when new value != old value.
 *   3. If the payload has at least one non-header key, publish a Platform Event.
 *   4. Inspect SaveResult[] from EventBus.publish():
 *      - Account path: failures trigger sfdc_account_updatedFailed__e publication.
 *      - Contact path: failures are logged only.
 *
 * Bulkification: all records are processed in a single loop;
 * events are collected and published in one EventBus.publish() call.
 * No SOQL is issued during execution (CMT uses getAll() via the cache).
 */
public with sharing class FieldMappingService {

    // ─── Inner Types ─────────────────────────────────────────────────────────────

    /**
     * Carries the built payload alongside the header identifiers
     * needed to populate both the Success and Failed events.
     */
    @TestVisible
    private class PayloadResult {
        String updatedFieldsJson;
        String acctCaseSafeId;
        String uLabAcctNumber;

        PayloadResult(String updatedFieldsJson, String acctCaseSafeId, String uLabAcctNumber) {
            this.updatedFieldsJson = updatedFieldsJson;
            this.acctCaseSafeId    = acctCaseSafeId;
            this.uLabAcctNumber    = uLabAcctNumber;
        }
    }

    // ─── Public API ─────────────────────────────────────────────────────────────

    /**
     * Publishes sfdc_account_updatedSuccess__e events for updated Account records.
     * Publish failures are captured and re-published as sfdc_account_updatedFailed__e.
     *
     * @param newRecords  Trigger.new — the updated Account records (new values).
     * @param oldMap      Trigger.oldMap — the pre-update Account values keyed by Id.
     */
    public static void publishAccountEvents(
        List<Account> newRecords,
        Map<Id, Account> oldMap
    ) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }

        List<Event_Field_Mapping__mdt> mappings =
            FieldMappingSelectorCache.getMappings('Account');

        if (mappings.isEmpty()) {
            return;
        }

        List<sfdc_account_updatedSuccess__e> successEvents = new List<sfdc_account_updatedSuccess__e>();
        List<PayloadResult>                  payloadResults = new List<PayloadResult>();

        for (Account newAcc : newRecords) {
            Account oldAcc = (oldMap != null) ? oldMap.get(newAcc.Id) : null;
            Map<String, Object> payloadMap = buildPayload(newAcc, oldAcc, mappings);

            if (payloadMap == null) {
                continue; // No non-header fields changed
            }

            String caseSafeId  = (String) newAcc.get('AcctCaseSafeID__c');
            String uLabAcctNum = (String) newAcc.get('uLab_Acct_Number__c');

            // Separate header fields from delta fields for Updated_Fields__c
            Map<String, Object> deltaOnly = new Map<String, Object>(payloadMap);
            deltaOnly.remove('AcctCaseSafeID__c');
            deltaOnly.remove('uLab_Acct_Number__c');

            PayloadResult pr = new PayloadResult(
                JSON.serialize(deltaOnly),
                caseSafeId,
                uLabAcctNum
            );
            payloadResults.add(pr);

            successEvents.add(new sfdc_account_updatedSuccess__e(
                AcctCaseSafeID__c    = caseSafeId,
                uLab_Acct_Number__c  = uLabAcctNum,
                Updated_Fields__c    = pr.updatedFieldsJson
            ));
        }

        if (successEvents.isEmpty()) {
            return;
        }

        List<Database.SaveResult> results = EventBus.publish(successEvents);
        publishAccountFailedEvents(results, payloadResults);
    }

    /**
     * Publishes sfdc_user_updatedSuccess__e events for updated Contact records.
     * Publish failures are captured and re-published as sfdc_user_updatedFailed__e.
     *
     * @param newRecords  Trigger.new — the updated Contact records (new values).
     * @param oldMap      Trigger.oldMap — the pre-update Contact values keyed by Id.
     */
    public static void publishContactEvents(
        List<Contact> newRecords,
        Map<Id, Contact> oldMap
    ) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }

        List<Event_Field_Mapping__mdt> mappings =
            FieldMappingSelectorCache.getMappings('Contact');

        if (mappings.isEmpty()) {
            return;
        }

        List<sfdc_user_updatedSuccess__e> successEvents = new List<sfdc_user_updatedSuccess__e>();
        List<PayloadResult>               payloadResults = new List<PayloadResult>();

        for (Contact newCon : newRecords) {
            Contact oldCon = (oldMap != null) ? oldMap.get(newCon.Id) : null;
            Map<String, Object> payloadMap = buildPayload(newCon, oldCon, mappings);

            if (payloadMap == null) {
                continue; // No non-header fields changed
            }

            String caseSafeId  = (String) newCon.get('ContactCaseSafeID__c');
            String portalUserId = (String) newCon.get('Portal_User_ID__c');

            // Separate header fields from delta fields for Updated_Fields__c
            Map<String, Object> deltaOnly = new Map<String, Object>(payloadMap);
            deltaOnly.remove('ContactCaseSafeID__c');
            deltaOnly.remove('Portal_User_ID__c');

            PayloadResult pr = new PayloadResult(
                JSON.serialize(deltaOnly),
                caseSafeId,
                portalUserId
            );
            payloadResults.add(pr);

            successEvents.add(new sfdc_user_updatedSuccess__e(
                ContactCaseSafeID__c = caseSafeId,
                Portal_User_ID__c    = portalUserId,
                Updated_Fields__c    = pr.updatedFieldsJson
            ));
        }

        if (successEvents.isEmpty()) {
            return;
        }

        List<Database.SaveResult> results = EventBus.publish(successEvents);
        publishContactFailedEvents(results, payloadResults);
    }

    // ─── Package-Private (TestVisible) Core ────────────────────────────────────

    /**
     * Generic publish logic — retained for @TestVisible direct invocation in tests.
     * Not used by the Account or Contact production paths.
     *
     * @param newRecords     Bulk list of updated records (new state).
     * @param oldMap         Map of Id → old record state.
     * @param objectApiName  SObject API name used to filter CMT mappings.
     * @param eventApiName   Platform Event API name to instantiate and publish.
     */
    @TestVisible
    private static void publishEvents(
        List<SObject> newRecords,
        Map<Id, SObject> oldMap,
        String objectApiName,
        String eventApiName
    ) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }

        List<Event_Field_Mapping__mdt> mappings =
            FieldMappingSelectorCache.getMappings(objectApiName);

        if (mappings.isEmpty()) {
            return;
        }

        List<SObject> eventsToPublish = new List<SObject>();

        for (SObject newRec : newRecords) {
            SObject oldRec = oldMap.get((Id) newRec.get('Id'));
            Map<String, Object> payload = buildPayload(newRec, oldRec, mappings);

            if (payload == null) {
                continue; // No non-header fields changed
            }

            SObject evt = Schema.getGlobalDescribe().get(eventApiName).newSObject();
            evt.put('Payload__c', JSON.serialize(payload));
            eventsToPublish.add(evt);
        }

        if (!eventsToPublish.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
            logPublishResults(results, objectApiName);
        }
    }

    // ─── Private Helpers ────────────────────────────────────────────────────────

    /**
     * Inspects SaveResult[] from the Account success publish and fires
     * sfdc_account_updatedFailed__e for every failed result.
     *
     * Each failed event carries the same header identifiers as the attempted
     * success event, plus Status_Code__c, Error_Code__c, and Error_Message__c
     * from the first Database.Error on the failed SaveResult.
     *
     * @param results        SaveResult list returned by EventBus.publish().
     * @param payloadResults Parallel list of PayloadResult built before publish.
     */
    private static void publishAccountFailedEvents(
        List<Database.SaveResult> results,
        List<PayloadResult> payloadResults
    ) {
        List<sfdc_account_updatedFailed__e> failedEvents = new List<sfdc_account_updatedFailed__e>();

        for (Integer i = 0; i < results.size(); i++) {
            Database.SaveResult sr = results[i];
            if (sr.isSuccess()) {
                continue;
            }

            PayloadResult pr = payloadResults[i];
            Database.Error firstErr = sr.getErrors()[0];

            System.debug(
                LoggingLevel.ERROR,
                'FieldMappingService: Failed to publish sfdc_account_updatedSuccess__e'
                + ' for AcctCaseSafeID=' + pr.acctCaseSafeId
                + ' — ' + firstErr.getStatusCode() + ': ' + firstErr.getMessage()
            );

            failedEvents.add(new sfdc_account_updatedFailed__e(
                AcctCaseSafeID__c   = pr.acctCaseSafeId,
                uLab_Acct_Number__c = pr.uLabAcctNumber,
                Updated_Fields__c   = pr.updatedFieldsJson,
                Status_Code__c      = firstErr.getStatusCode().ordinal(),
                Error_Code__c       = String.valueOf(firstErr.getStatusCode()),
                Error_Message__c    = firstErr.getMessage()
            ));
        }

        if (!failedEvents.isEmpty()) {
            List<Database.SaveResult> failResults = EventBus.publish(failedEvents);
            logPublishResults(failResults, 'sfdc_account_updatedFailed__e');
        }
    }

    /**
     * Inspects SaveResult[] from the Contact success publish and fires
     * sfdc_user_updatedFailed__e for every failed result.
     *
     * @param results        SaveResult list returned by EventBus.publish().
     * @param payloadResults Parallel list of PayloadResult built before publish.
     */
    private static void publishContactFailedEvents(
        List<Database.SaveResult> results,
        List<PayloadResult> payloadResults
    ) {
        List<sfdc_user_updatedFailed__e> failedEvents = new List<sfdc_user_updatedFailed__e>();

        for (Integer i = 0; i < results.size(); i++) {
            Database.SaveResult sr = results[i];
            if (sr.isSuccess()) {
                continue;
            }

            PayloadResult pr = payloadResults[i];
            Database.Error firstErr = sr.getErrors()[0];

            System.debug(
                LoggingLevel.ERROR,
                'FieldMappingService: Failed to publish sfdc_user_updatedSuccess__e'
                + ' for ContactCaseSafeID=' + pr.acctCaseSafeId
                + ' — ' + firstErr.getStatusCode() + ': ' + firstErr.getMessage()
            );

            failedEvents.add(new sfdc_user_updatedFailed__e(
                ContactCaseSafeID__c = pr.acctCaseSafeId,
                Portal_User_ID__c    = pr.uLabAcctNumber,
                Updated_Fields__c    = pr.updatedFieldsJson,
                Status_Code__c       = firstErr.getStatusCode().ordinal(),
                Error_Code__c        = String.valueOf(firstErr.getStatusCode()),
                Error_Message__c     = firstErr.getMessage()
            ));
        }

        if (!failedEvents.isEmpty()) {
            List<Database.SaveResult> failResults = EventBus.publish(failedEvents);
            logPublishResults(failResults, 'sfdc_user_updatedFailed__e');
        }
    }

    /**
     * Builds the JSON payload map for a single record.
     *
     * Header fields (Is_Header_Field__c = true) are always included.
     * Non-header fields are included only when new value != old value.
     * Payload keys are the Salesforce field API names (Salesforce_Field__c).
     *
     * @param newRec    The record's new state.
     * @param oldRec    The record's old state; must not be null for delta comparison.
     * @param mappings  Active CMT mappings for the object.
     * @return          A non-null payload Map if at least one non-header field changed;
     *                  null if only header fields are present (no event needed).
     */
    private static Map<String, Object> buildPayload(
        SObject newRec,
        SObject oldRec,
        List<Event_Field_Mapping__mdt> mappings
    ) {
        Map<String, Object> payload = new Map<String, Object>();
        Boolean hasChangedField = false;

        for (Event_Field_Mapping__mdt mapping : mappings) {
            String sfField = mapping.Salesforce_Field__c;
            Object newVal = newRec.get(sfField);

            if (mapping.Is_Header_Field__c) {
                payload.put(sfField, newVal);
            } else {
                Object oldVal = (oldRec != null) ? oldRec.get(sfField) : null;
                if (newVal != oldVal) {
                    payload.put(sfField, newVal);
                    hasChangedField = true;
                }
            }
        }

        return hasChangedField ? payload : null;
    }

    /**
     * Logs failed SaveResults from EventBus.publish() at ERROR level.
     * Does NOT throw — the caller's DML transaction continues regardless.
     *
     * @param results        The SaveResult list returned by EventBus.publish().
     * @param objectApiName  The SObject name for context in log messages.
     */
    private static void logPublishResults(
        List<Database.SaveResult> results,
        String objectApiName
    ) {
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug(
                        LoggingLevel.ERROR,
                        'FieldMappingService: Failed to publish event for ' + objectApiName
                        + ' — ' + err.getStatusCode() + ': ' + err.getMessage()
                    );
                }
            }
        }
    }
}
