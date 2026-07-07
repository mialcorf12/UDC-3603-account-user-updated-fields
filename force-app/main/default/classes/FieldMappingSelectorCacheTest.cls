/**
 * Unit tests for FieldMappingSelectorCache.
 *
 * Tests zero-SOQL CMT access, per-object filtering, cache hit behaviour,
 * and the @TestVisible clearCache() reset path.
 *
 * Note on CMT in test context:
 *   Event_Field_Mapping__mdt.getAll() returns every deployed CMT record.
 *   In the target sandbox, 38 records (21 Account + 17 Contact) are deployed.
 *   Tests assert structure (not null, is a List) and observable cache behaviour
 *   rather than exact counts so they remain portable across orgs.
 */
@isTest
private class FieldMappingSelectorCacheTest {

    // ─── Scenario 1: getMappings for known object returns a List (not null) ─────

    @isTest
    static void getMappings_Account_ReturnsListNotNull() {
        // Given / When
        Test.startTest();
        List<Event_Field_Mapping__mdt> result = FieldMappingSelectorCache.getMappings('Account');
        Test.stopTest();

        // Then — must return a non-null List (size may vary by org)
        Assert.isNotNull(result, 'getMappings(Account) must never return null');
        Assert.isTrue(result instanceof List<Event_Field_Mapping__mdt>,
            'getMappings must return a List<Event_Field_Mapping__mdt>');
    }

    // ─── Scenario 2: getMappings for Contact returns a List (not null) ──────────

    @isTest
    static void getMappings_Contact_ReturnsListNotNull() {
        // Given / When
        Test.startTest();
        List<Event_Field_Mapping__mdt> result = FieldMappingSelectorCache.getMappings('Contact');
        Test.stopTest();

        // Then
        Assert.isNotNull(result, 'getMappings(Contact) must never return null');
    }

    // ─── Scenario 3: getMappings for unknown object returns empty list ───────────

    @isTest
    static void getMappings_UnknownObject_ReturnsEmptyList() {
        // Given — no CMT records exist for 'Opportunity__NoSuchObject'
        Test.startTest();
        List<Event_Field_Mapping__mdt> result =
            FieldMappingSelectorCache.getMappings('Opportunity__NoSuchObject');
        Test.stopTest();

        // Then — empty list, not null
        Assert.isNotNull(result, 'getMappings for unknown object must return an empty list, not null');
        Assert.areEqual(0, result.size(),
            'getMappings for unknown object must return an empty list');
    }

    // ─── Scenario 4: Calling getMappings twice returns the same list reference ──
    //     (cache hit — the static Map is reused, no second filtering pass)

    @isTest
    static void getMappings_CalledTwice_ReturnsSameReference() {
        // Given — ensure a clean cache state
        FieldMappingSelectorCache.clearCache();

        // When — two calls for the same object
        List<Event_Field_Mapping__mdt> first  = FieldMappingSelectorCache.getMappings('Account');
        List<Event_Field_Mapping__mdt> second = FieldMappingSelectorCache.getMappings('Account');

        // Then — same object reference proves the cache was hit on the second call
        Assert.isTrue(first === second,
            'Second call should return the exact same List reference from the cache');
    }

    // ─── Scenario 5: clearCache() causes next call to rebuild (new reference) ───

    @isTest
    static void clearCache_ThenGetMappings_ReturnsNewReference() {
        // Given — prime the cache
        List<Event_Field_Mapping__mdt> before = FieldMappingSelectorCache.getMappings('Account');

        // When — clear and re-query
        FieldMappingSelectorCache.clearCache();
        List<Event_Field_Mapping__mdt> after = FieldMappingSelectorCache.getMappings('Account');

        // Then — a new List was created (different reference), same logical content
        Assert.isFalse(before === after,
            'After clearCache(), getMappings should return a new List, not the evicted reference');
        Assert.areEqual(before.size(), after.size(),
            'Rebuilt cache should return the same number of records');
    }

    // ─── Scenario 6: Zero SOQL consumed (CMT via getAll()) ──────────────────────

    @isTest
    static void getMappings_ConsumesZeroSoql() {
        // Given — start with clean cache
        FieldMappingSelectorCache.clearCache();
        Integer queriesBefore = Limits.getQueries();

        // When
        Test.startTest();
        FieldMappingSelectorCache.getMappings('Account');
        Integer queriesAfter = Limits.getQueries();
        Test.stopTest();

        // Then — getAll() never issues SOQL; governor count must not increment
        Assert.areEqual(queriesBefore, queriesAfter,
            'FieldMappingSelectorCache.getMappings must consume exactly 0 SOQL queries');
    }

    // ─── Scenario 7: Only Is_Active__c = true records returned for Account ──────

    @isTest
    static void getMappings_Account_ReturnsOnlyActiveRecords() {
        // Given / When
        List<Event_Field_Mapping__mdt> result = FieldMappingSelectorCache.getMappings('Account');

        // Then — every returned record must have Is_Active__c = true
        for (Event_Field_Mapping__mdt mdt : result) {
            Assert.isTrue(mdt.Is_Active__c,
                'getMappings must only return records where Is_Active__c is true. '
                + 'Found inactive: ' + mdt.DeveloperName);
        }
    }

    // ─── Scenario 8: Every returned record belongs to the requested object ───────

    @isTest
    static void getMappings_Account_ReturnsOnlyAccountMappings() {
        // Given / When
        List<Event_Field_Mapping__mdt> result = FieldMappingSelectorCache.getMappings('Account');

        // Then — every record must have Object_API_Name__c == 'Account'
        for (Event_Field_Mapping__mdt mdt : result) {
            Assert.areEqual('Account', mdt.Object_API_Name__c,
                'getMappings(Account) must only return records for Account. '
                + 'Found: ' + mdt.Object_API_Name__c + ' on ' + mdt.DeveloperName);
        }
    }
}
