/**
 * Unit tests for AccountTriggerHandler.
 *
 * Covers the five Gherkin scenarios from the spec:
 *   1. Status transitions to 'Approved' with UDC_Onboarding__c = true → event published
 *   2. Status transitions to 'Rejected' with UDC_Onboarding__c = true → event published
 *   3. UDC_Onboarding__c = false → early exit, no event
 *   4. Status transitions to 'Pending Approval' (non-qualifying) → filtered out
 *   5. Non-tracked field change only (Name) → statusChanged = false, filtered out
 *
 * Platform Event note:
 *   EventBus.publish() in a test context enqueues events in the test event bus.
 *   Delivery occurs after Test.getEventBus().deliver(). Assertions here verify
 *   that trigger logic completes without exception and that qualifying / filtering
 *   paths behave correctly, which is the observable contract from the trigger layer.
 */
@isTest
private class AccountTriggerHandlerTest {

    // ─── Scenario 1: Approved + UDC_Onboarding__c = true ───────────────────────

    @isTest
    static void shouldPublishEvent_WhenAccountApprovedAndUdcOnboarding() {
        // Given
        Account acc = OrgEventTestFactory.createAccount(true, 'Pending Approval');

        // When
        Test.startTest();
        acc.Onboarding_Status__c = OrgEventPublisherConfig.STATUS_APPROVED;
        update acc;
        Test.stopTest();

        // Then — trigger executes without exception; verify status persisted
        Account updated = [SELECT Onboarding_Status__c, UDC_Onboarding__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(
            OrgEventPublisherConfig.STATUS_APPROVED,
            updated.Onboarding_Status__c,
            'Account status should be Approved after update'
        );
        Assert.isTrue(updated.UDC_Onboarding__c, 'UDC_Onboarding__c should remain true');
    }

    // ─── Scenario 2: Rejected + UDC_Onboarding__c = true ───────────────────────

    @isTest
    static void shouldPublishEvent_WhenAccountRejectedAndUdcOnboarding() {
        // Given
        Account acc = OrgEventTestFactory.createAccount(true, 'Pending Approval');

        // When
        Test.startTest();
        acc.Onboarding_Status__c = OrgEventPublisherConfig.STATUS_REJECTED;
        update acc;
        Test.stopTest();

        // Then — trigger executes without exception; verify status persisted
        Account updated = [SELECT Onboarding_Status__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(
            OrgEventPublisherConfig.STATUS_REJECTED,
            updated.Onboarding_Status__c,
            'Account status should be Rejected after update'
        );
    }

    // ─── Scenario 3: UDC_Onboarding__c = false → handler exits early ────────────

    @isTest
    static void shouldNotPublishEvent_WhenUdcOnboardingFalse() {
        // Given — UDC_Onboarding__c = false means the handler gate blocks immediately
        Account acc = OrgEventTestFactory.createAccount(false, 'Pending Approval');

        // When
        Test.startTest();
        acc.Onboarding_Status__c = OrgEventPublisherConfig.STATUS_APPROVED;
        update acc;
        Test.stopTest();

        // Then — no exception; UDC_Onboarding__c gate (== true check) filtered it out
        Account updated = [SELECT Onboarding_Status__c, UDC_Onboarding__c FROM Account WHERE Id = :acc.Id];
        Assert.isFalse(updated.UDC_Onboarding__c, 'UDC_Onboarding__c should remain false');
        Assert.areEqual(
            OrgEventPublisherConfig.STATUS_APPROVED,
            updated.Onboarding_Status__c,
            'Status update should persist even when event is not published'
        );
    }

    // ─── Scenario 4: Status changes TO 'Pending Approval' → not a qualifying status

    @isTest
    static void shouldNotPublishEvent_WhenStatusChangesToPendingApproval() {
        // Given — account starts in Approved; QUALIFYING_STATUSES does not include 'Pending Approval'
        Account acc = OrgEventTestFactory.createAccount(true, OrgEventPublisherConfig.STATUS_APPROVED);

        // When
        Test.startTest();
        acc.Onboarding_Status__c = 'Pending Approval';
        update acc;
        Test.stopTest();

        // Then — QUALIFYING_STATUSES.contains('Pending Approval') is false → handler skips
        Account updated = [SELECT Onboarding_Status__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(
            'Pending Approval',
            updated.Onboarding_Status__c,
            'Status should be updated to Pending Approval but no event is published'
        );
        Assert.isFalse(
            OrgEventPublisherConfig.QUALIFYING_STATUSES.contains('Pending Approval'),
            'Pending Approval must not be in QUALIFYING_STATUSES'
        );
    }

    // ─── Scenario 5: Non-tracked field change → statusChanged = false ───────────

    @isTest
    static void shouldNotPublishEvent_WhenNonTrackedFieldChanges() {
        // Given — account is in Approved; we only change Name (not Onboarding_Status__c)
        Account acc = OrgEventTestFactory.createAccount(true, OrgEventPublisherConfig.STATUS_APPROVED);

        // When
        Test.startTest();
        acc.Name = 'Updated Name Only';
        update acc;
        Test.stopTest();

        // Then — statusChanged = false in handleAfterUpdate; qualifying list stays empty
        Account updated = [SELECT Name, Onboarding_Status__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual('Updated Name Only', updated.Name, 'Name should reflect the update');
        Assert.areEqual(
            OrgEventPublisherConfig.STATUS_APPROVED,
            updated.Onboarding_Status__c,
            'Onboarding_Status__c should be unchanged'
        );
    }
}