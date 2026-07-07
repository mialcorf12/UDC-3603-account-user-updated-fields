/**
 * Configuration constants for OrgEventPublisher.
 * To add a new tracked field, update the relevant list here — no other class changes needed.
 */
public with sharing class OrgEventPublisherConfig {

    // Platform Event
    public static final String EVENT_TYPE = 'sfdc.account.updated';

    // Qualifying Onboarding_Status__c values that trigger event publication
    public static final String STATUS_APPROVED = 'Approved';
    public static final String STATUS_REJECTED  = 'Rejected';
    public static final Set<String> QUALIFYING_STATUSES = new Set<String>{
        STATUS_APPROVED,
        STATUS_REJECTED
    };

    // Account field that holds the uDC org_id
    public static final String ORG_ID_SOURCE = 'uLab_Acct_Number__c';

    // Tracked Account fields for change-delta payload (add new tracked fields here)
    public static final List<String> TRACKED_ACCOUNT_FIELDS = new List<String>{
        'Onboarding_Status__c'
    };

    // Tracked Contact fields for current-value payload (add new tracked fields here)
    public static final List<String> TRACKED_CONTACT_FIELDS = new List<String>{
        'Contact_Role__c'
    };

    // Fields to SELECT on Contact when querying related records
    public static final String CONTACT_QUERY_FIELDS =
        'AccountId, Portal_User_ID__c, Contact_Role__c, CreatedDate';
}