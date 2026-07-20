public without sharing class ContactTriggerHandler {
	/**
	 * Handles Contact trigger events for dynamic field-change Platform Event publishing.
	 *
	 * This handler is the Contact-side counterpart of AccountTriggerHandler. It delegates
	 * to FieldMappingService which evaluates old-vs-new field deltas using Event_Field_Mapping__mdt
	 * CMT records and publishes sfdc_user_updated__e Platform Events for mapped field changes.
	 *
	 * Bulkification: accepts collections directly from Trigger.new and Trigger.oldMap;
	 * SOQL and DML occur inside FieldMappingService, never in loops here.
	 */

	 /**
     * Called from ContactTrigger on after update.
     * Delegates to FieldMappingService to evaluate field deltas and publish
     * sfdc_user_updated__e Platform Events for any mapped field changes.
     *
     * @param newRecords  Trigger.new — the updated Contact records (new values).
     * @param oldMap      Trigger.oldMap — the pre-update Contact values keyed by Id.
     */
    public static void handleDynamicUpdate(
        List<Contact> newRecords,
        Map<Id, Contact> oldMap
    ) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }
        FieldMappingService.publishContactEvents(newRecords, oldMap);
    }
}