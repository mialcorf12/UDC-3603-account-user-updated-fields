public with sharing class AccountTriggerHandler {

    /**
     * Called from AccountTrigger on after update (dynamic field-change path).
     * Delegates to FieldMappingService which evaluates old-vs-new field deltas using
     * Event_Field_Mapping__mdt CMT records and publishes sfdc_account_updated__e
     * Platform Events for any mapped field changes.
     *
     * This method runs alongside handleAfterUpdate (UDC-3865) without interference.
     *
     * @param newRecords  Trigger.new — the updated Account records (new values).
     * @param oldMap      Trigger.oldMap — the pre-update Account values keyed by Id.
     */
    public static void handleDynamicUpdate(
        List<Account> newRecords,
        Map<Id, Account> oldMap
    ) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }
        FieldMappingService.publishAccountEvents(newRecords, oldMap);
    }
}