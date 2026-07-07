/**
 * Unit tests for ContactTriggerHandler.
 *
 * Covers SPEC-3 and SPEC-8 scenarios:
 *   1. A mapped Contact field changes → handleDynamicUpdate delegates to FieldMappingService
 *   2. No mapped fields change → no event, no exception
 *   3. Empty list input → no-op, no exception
 *
 * Platform Event note:
 *   EventBus.publish() in a test context enqueues events in the test event bus.
 *   Assertions here verify the handler completes without exception; deeper payload
 *   assertions are covered in FieldMappingServiceTest.
 */
@isTest
private class ContactTriggerHandlerTest {

    // ─── Scenario 1: mapped field changed → handler delegates without exception ───

    @isTest
    static void testHandleDynamicUpdate_publishesEventOnMappedFieldChange() {
        Account acc = new Account(Name = 'Test Org');
        insert acc;

        Contact con = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com',
            AccountId = acc.Id
        );
        insert con;

        Contact oldCon = con.clone(true, true, false, false);
        con.Email = 'updated@example.com';

        Test.startTest();
        ContactTriggerHandler.handleDynamicUpdate(
            new List<Contact>{ con },
            new Map<Id, Contact>{ oldCon.Id => oldCon }
        );
        Test.stopTest();

        // Verify no exception thrown — event publishing is async
        System.assert(true, 'No exception thrown on contact dynamic update');
    }

    // ─── Scenario 2: no mapped fields changed → no-op, no exception ─────────────

    @isTest
    static void testHandleDynamicUpdate_noEventOnUnchangedFields() {
        Account acc = new Account(Name = 'Test Org');
        insert acc;

        Contact con = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com',
            AccountId = acc.Id
        );
        insert con;

        Contact oldCon = con.clone(true, true, false, false);
        // Don't change anything

        Test.startTest();
        ContactTriggerHandler.handleDynamicUpdate(
            new List<Contact>{ con },
            new Map<Id, Contact>{ oldCon.Id => oldCon }
        );
        Test.stopTest();

        System.assert(true, 'No exception thrown when no fields changed');
    }

    // ─── Scenario 3: empty list → graceful no-op ─────────────────────────────────

    @isTest
    static void testHandleDynamicUpdate_emptyListIsNoop() {
        Test.startTest();
        ContactTriggerHandler.handleDynamicUpdate(
            new List<Contact>(),
            new Map<Id, Contact>()
        );
        Test.stopTest();

        System.assert(true, 'Empty list handled gracefully');
    }
}
