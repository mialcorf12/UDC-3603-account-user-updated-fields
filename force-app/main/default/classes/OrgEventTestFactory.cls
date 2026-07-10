/**
 * Shared test data factory for OrgEventPublisher-related test classes.
 * Centralizes record creation to keep test methods focused on behavior.
 */
@isTest
public class OrgEventTestFactory {

    /**
     * Creates and inserts a single Account for trigger testing.
     *
     * @param udcOnboarding     Value for UDC_Onboarding__c
     * @param onboardingStatus  Value for Onboarding_Status__c (e.g. 'Pending Approval', 'Approved')
     * @return Inserted Account record
     */
    public static Account createAccount(Boolean udcOnboarding, String onboardingStatus) {
        Account acc = new Account(
            Name                 = 'Test Org',
            UDC_Onboarding__c    = udcOnboarding,
            Onboarding_Status__c = onboardingStatus
        );
        insert acc;
        return acc;
    }

    /**
     * Creates and inserts a Contact linked to an Account.
     *
     * @param accountId     Parent Account Id
     * @param portalUserId  Value for Portal_User_ID__c
     * @param contactRole   Value for Contact_Role__c
     * @return Inserted Contact record
     */
    public static Contact createContact(Id accountId, String portalUserId, String contactRole) {
        Contact con = new Contact(
            FirstName             = 'Test',
            LastName              = 'Tester',
            AccountId             = accountId,
            Portal_User_ID__c     = portalUserId,
            Contact_Role__c       = contactRole,
            Company_User_Type__c  = 'Account User',
            Phone                 = '5555555555',
            Email                 = 'test.contact@example.com',
            MailingStreet         = '123 Test St',
            MailingCity           = 'Testville',
            MailingState          = 'CA',
            MailingPostalCode     = '90001',
            MailingCountry        = 'US'
        );
        insert con;
        return con;
    }

    /**
     * Creates and inserts a bulk list of Accounts.
     * Use count >= 201 to cross the Salesforce 200-record batch boundary.
     *
     * @param count             Number of Account records to create
     * @param udcOnboarding     Value for UDC_Onboarding__c on every record
     * @param onboardingStatus  Value for Onboarding_Status__c on every record
     * @return List of inserted Account records
     */
    public static List<Account> createAccountList(Integer count, Boolean udcOnboarding, String onboardingStatus) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name                 = 'Test Org ' + i,
                UDC_Onboarding__c    = udcOnboarding,
                Onboarding_Status__c = onboardingStatus
            ));
        }
        insert accounts;
        return accounts;
    }
}