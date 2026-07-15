/**
 * Publishes Platform Events for Account and Contact updates driven by
 * Custom Metadata Type (CMT) field mappings.
 *
 * Core algorithm per record:
 *   1. Load active CMT mappings from FieldMappingSelectorCache (0 SOQL).
 *   2. Build a Map<String, Object> payload using Salesforce_Field__c as the key:
 *      - Header fields (Is_Header_Field__c = true): always added.
 *      - Non-header fields: added only when new value != old value.
 *   3. If the payload has at least one non-header key, publish a Platform Event.
 *   4. Inspect SaveResult[] from EventBus.publish(); log any failures.
 *
 * Bulkification: all records are processed in a single loop;
 * events are collected and published in one EventBus.publish() call.
 * No SOQL is issued during execution (CMT uses getAll() via the cache).
 */
public with sharing class FieldMappingService {

    // ─── Public API ─────────────────────────────────────────────────────────────

    /**
     * Publishes sfdc_account_updated__e events for updated Account records.
     *
     * @param newRecords  Trigger.new — the updated Account records (new values).
     * @param oldMap      Trigger.oldMap — the pre-update Account values keyed by Id.
     */
    public static void publishAccountEvents(
        List<Account> newRecords,
        Map<Id, Account> oldMap
    ) {
        publishEvents(newRecords, oldMap, 'Account', 'sfdc_account_updated__e');
    }

    /**
     * Publishes sfdc_user_updated__e events for updated Contact records.
     *
     * @param newRecords  Trigger.new — the updated Contact records (new values).
     * @param oldMap      Trigger.oldMap — the pre-update Contact values keyed by Id.
     */
    public static void publishContactEvents(
        List<Contact> newRecords,
        Map<Id, Contact> oldMap
    ) {
        publishEvents(newRecords, oldMap, 'Contact', 'sfdc_user_updated__e');
    }

    // ─── Package-Private (TestVisible) Core ────────────────────────────────────

    /**
     * Generic publish logic shared by Account and Contact paths.
     * Exposed as @TestVisible to allow direct invocation with SObject collections.
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
    @TestVisible
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
