/**
 * Caches Event_Field_Mapping__mdt records per SObject API name.
 *
 * Uses CMT.getAll() — zero SOQL consumed per transaction.
 * A static Map stores the filtered list per object so repeated calls
 * within the same Apex execution (e.g. bulk triggers) hit the cache.
 */
public with sharing class FieldMappingSelectorCache {

    private static Map<String, List<Event_Field_Mapping__mdt>> cacheByObject =
        new Map<String, List<Event_Field_Mapping__mdt>>();

    /**
     * Returns active mappings for the given SObject API name.
     * Results are cached in a static Map — safe for bulk triggers (0 SOQL).
     *
     * @param objectApiName  The SObject API name to filter by (e.g. 'Account', 'Contact').
     * @return               A non-null List of active Event_Field_Mapping__mdt records.
     */
    public static List<Event_Field_Mapping__mdt> getMappings(String objectApiName) {
        if (!cacheByObject.containsKey(objectApiName)) {
            List<Event_Field_Mapping__mdt> filtered = new List<Event_Field_Mapping__mdt>();
            for (Event_Field_Mapping__mdt mdt : Event_Field_Mapping__mdt.getAll().values()) {
                if (mdt.Object_API_Name__c == objectApiName && mdt.Is_Active__c) {
                    filtered.add(mdt);
                }
            }
            cacheByObject.put(objectApiName, filtered);
        }
        return cacheByObject.get(objectApiName);
    }

    /**
     * Clears the static cache. For testing purposes only.
     * Allows tests to reset state between scenarios without re-deploying.
     */
    @TestVisible
    private static void clearCache() {
        cacheByObject.clear();
    }
}