/**
 * Publishes Org_Event__e platform events for qualifying Account changes.
 *
 * Responsibilities:
 * - Queries the oldest Contact per Account (single SOQL, bulkified)
 * - Builds a field-delta JSON payload per Account
 * - Publishes all events in a single EventBus.publish() call
 * - Logs publish failures via System.debug — does NOT throw exceptions
 *
 * Account tracked fields use change-delta (old vs new).
 * Contact tracked fields use current value only (old Contact state
 * is unavailable in the Account trigger context).
 */
public with sharing class OrgEventPublisher {

    /**
     * Builds and publishes Org_Event__e events for the provided Accounts.
     *
     * @param accounts  The qualifying Account records (new values). Must not be null or empty.
     * @param oldMap    The trigger oldMap for change-delta comparison; pass null on insert.
     */
    public static void publishEvents(List<Account> accounts, Map<Id, Account> oldMap) {
        if (accounts == null || accounts.isEmpty()) {
            return;
        }

        Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
        Map<Id, Contact> contactByAccountId = queryFirstContacts(accountIds);

        List<Org_Event__e> events = new List<Org_Event__e>();
        for (Account acc : accounts) {
            Account oldAcc = (oldMap != null) ? oldMap.get(acc.Id) : null;
            Contact con = contactByAccountId.get(acc.Id);
            Map<String, Object> delta = buildDelta(acc, oldAcc, con);

            events.add(new Org_Event__e(
                Org_Id__c       = (String) acc.get(OrgEventPublisherConfig.ORG_ID_SOURCE),
                Org_SFDC_Id__c  = acc.Id,
                User_Id__c      = (con != null) ? con.Portal_User_ID__c : null,
                Event_Type__c   = OrgEventPublisherConfig.EVENT_TYPE,
                Field_Deltas__c = JSON.serialize(delta)
            ));
        }

        List<Database.SaveResult> results = EventBus.publish(events);
        logFailures(results);
    }

    // ─── Private Helpers ────────────────────────────────────────────────────────

    /**
     * Returns a map of AccountId → oldest Contact (by CreatedDate ASC).
     * Uses a single SOQL query across all accountIds.
     *
     * @param accountIds  Set of Account Ids to query Contacts for.
     * @return Map<Id, Contact> with at most one Contact entry per Account.
     */
    private static Map<Id, Contact> queryFirstContacts(Set<Id> accountIds) {
        Map<Id, Contact> firstByAccount = new Map<Id, Contact>();
        for (Contact con : [
            SELECT AccountId, Portal_User_ID__c, Contact_Role__c, CreatedDate
            FROM Contact
            WHERE AccountId IN :accountIds
            ORDER BY CreatedDate ASC
        ]) {
            if (!firstByAccount.containsKey(con.AccountId)) {
                firstByAccount.put(con.AccountId, con);
            }
        }
        return firstByAccount;
    }

    /**
     * Builds the field-delta payload map for a single Account.
     *
     * Account tracked fields: included only when the value changed (old vs new).
     * When oldAcc is null (insert context), the new value is always included.
     * Contact tracked fields: current value only — no old state available.
     *
     * @param newAcc  The Account's new state from Trigger.new.
     * @param oldAcc  The Account's old state from Trigger.oldMap; null on insert.
     * @param con     The oldest related Contact; null if none exists.
     * @return Map<String, Object> representing the field delta payload.
     */
    private static Map<String, Object> buildDelta(Account newAcc, Account oldAcc, Contact con) {
        Map<String, Object> delta = new Map<String, Object>();

        // Account tracked fields: change-delta (compare old vs new)
        for (String field : OrgEventPublisherConfig.TRACKED_ACCOUNT_FIELDS) {
            Object newVal = newAcc.get(field);
            Object oldVal = (oldAcc != null) ? oldAcc.get(field) : null;
            if (newVal != oldVal) {
                delta.put(field, newVal);
            }
        }

        // Contact tracked fields: current value only (no old Contact state available)
        if (con != null) {
            for (String field : OrgEventPublisherConfig.TRACKED_CONTACT_FIELDS) {
                delta.put(field, con.get(field));
            }
        }

        return delta;
    }

    /**
     * Logs any failed SaveResults from EventBus.publish() at ERROR level.
     * Does NOT throw — caller proceeds regardless of publish failures.
     *
     * @param results  The SaveResult list returned by EventBus.publish().
     */
    private static void logFailures(List<Database.SaveResult> results) {
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug(
                        LoggingLevel.ERROR,
                        'Org_Event__e publish failed: ' + err.getStatusCode() + ' — ' + err.getMessage()
                    );
                }
            }
        }
    }
}