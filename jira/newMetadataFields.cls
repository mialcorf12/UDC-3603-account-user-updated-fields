/**
 * Anonymous Apex script to deploy all Event_Field_Mapping__mdt records
 * via the Metadata API. Run this in Developer Console > Execute Anonymous
 * or with: sf apex run --file jira/newMetadataFields.cls --target-org Dev
 *
 * Use case: the sf project deploy start command throws UNKNOWN_EXCEPTION
 * when deploying CMT records immediately after the CMT object type is
 * created. This script bypasses that by using Metadata.Operations directly.
 *
 * Payload keys: Salesforce_Field__c is used directly as the JSON key.
 * JSON_Key__c has been removed from the CMT schema.
 *
 * Records: 21 Account + 20 Contact = 41 total
 */

Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();

// ============================================================
// ACCOUNT RECORDS (21)
// Headers: uLab_Acct_Number__c, AccountCaseSafeID__c
// ============================================================

// batch 1

// Account_uLab_Acct_Number  (HEADER)
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_uLab_Acct_Number';
    rec.label    = 'Account - uLab Acct Number';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'uLab_Acct_Number__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = true;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_AccountCaseSafeID  (HEADER)
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_AccountCaseSafeID';
    rec.label    = 'Account - Account Case Safe ID';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'AcctCaseSafeID__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = true;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Name
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Name';
    rec.label    = 'Account - Name';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Name';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Account_Email
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Account_Email';
    rec.label    = 'Account - Account Email';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Account_Email__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Company_Variant
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Company_Variant';
    rec.label    = 'Account - Company Variant';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Company_Variant__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Parent_Acct
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Parent_Acct';
    rec.label    = 'Account - Parent Acct';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Parent_Acct__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Is_Parent
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Is_Parent';
    rec.label    = 'Account - Is Parent';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Is_Parent__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Development_Specialist
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Development_Specialist';
    rec.label    = 'Account - Development Specialist';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Development_Specialist__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Integration_Specialist
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Integration_Specialist';
    rec.label    = 'Account - Integration Specialist';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Integration_Specialist__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Signature_Required
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Signature_Required';
    rec.label    = 'Account - Signature Required';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Signature_Required__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Out_of_Service_Area
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Out_of_Service_Area';
    rec.label    = 'Account - Out of Service Area';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Out_of_Service_Area__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}


// batch 2
// Account_Special_Handling
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Special_Handling';
    rec.label    = 'Account - Special Handling';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Special_Handling__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Custom_Box_Active
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Custom_Box_Active';
    rec.label    = 'Account - Custom Box Active';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Custom_Box_Active__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_uAssist_Customer
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_uAssist_Customer';
    rec.label    = 'Account - uAssist Customer';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'uAssist_Customer__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Invoice_Start_Date
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Invoice_Start_Date';
    rec.label    = 'Account - Invoice Start Date';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Invoice_Start_Date__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Process_Type
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Process_Type';
    rec.label    = 'Account - Process Type';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Process_Type__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Area_Sales_Director
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Area_Sales_Director';
    rec.label    = 'Account - Area Sales Director';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Area_Sales_Director__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Acct_Owner_Identified
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Acct_Owner_Identified';
    rec.label    = 'Account - Acct Owner Identified';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Acct_Owner_Identified__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Account_Setup_Completed
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Account_Setup_Completed';
    rec.label    = 'Account - Account Setup Completed';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Account_Setup_Completed__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Type
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Type';
    rec.label    = 'Account - Type';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Type';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Account_Status
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Account_Status';
    rec.label    = 'Account - Status';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Account_Status__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Account';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// batch 3
// ============================================================
// CONTACT RECORDS (20)
// Headers: Portal_User_ID__c, ContactCaseSafeID__c
// ============================================================

// Contact_Portal_User_ID  (HEADER)
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Portal_User_ID';
    rec.label    = 'Contact - Portal User ID';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Portal_User_ID__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = true;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_ContactCaseSafeID  (HEADER)
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_ContactCaseSafeID';
    rec.label    = 'Contact - Contact Case Safe ID';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'ContactCaseSafeID__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = true;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Email
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Email';
    rec.label    = 'Contact - Email';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Email';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_FirstName
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_FirstName';
    rec.label    = 'Contact - First Name';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'FirstName';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_LastName
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_LastName';
    rec.label    = 'Contact - Last Name';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'LastName';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Title
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Title';
    rec.label    = 'Contact - Title';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Title';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Salutation
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Salutation';
    rec.label    = 'Contact - Salutation';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Salutation';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Username
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Username';
    rec.label    = 'Contact - Username';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Username__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Phone
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Phone';
    rec.label    = 'Contact - Phone';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Phone';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_MobilePhone
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_MobilePhone';
    rec.label    = 'Contact - Mobile Phone';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'MobilePhone';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// batch 4
// Contact_MailingCity
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_MailingCity';
    rec.label    = 'Contact - Mailing City';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'MailingCity';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_MailingState
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_MailingState';
    rec.label    = 'Contact - Mailing State';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'MailingState';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_MailingPostalCode
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_MailingPostalCode';
    rec.label    = 'Contact - Mailing Postal Code';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'MailingPostalCode';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_MailingCountry
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_MailingCountry';
    rec.label    = 'Contact - Mailing Country';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'MailingCountry';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_MailingStreet
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_MailingStreet';
    rec.label    = 'Contact - Mailing Street';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'MailingStreet';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Preferred_Language
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Preferred_Language';
    rec.label    = 'Contact - Preferred Language';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Preferred_Language__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Contact_Role
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Contact_Role';
    rec.label    = 'Contact - Contact Role';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Contact_Role__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Communication_Preference
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Communication_Preference';
    rec.label    = 'Contact - Communication Preference';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Communication_Preference__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Company_User_Type
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Company_User_Type';
    rec.label    = 'Contact - Company User Type';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Company_User_Type__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}

// Contact_Status
{
    Metadata.CustomMetadata rec = new Metadata.CustomMetadata();
    rec.fullName = 'Event_Field_Mapping__mdt.Contact_Status';
    rec.label    = 'Contact - Status';
    Metadata.CustomMetadataValue f1 = new Metadata.CustomMetadataValue();
    f1.field = 'Salesforce_Field__c'; f1.value = 'Status__c';
    Metadata.CustomMetadataValue f2 = new Metadata.CustomMetadataValue();
    f2.field = 'Object_API_Name__c'; f2.value = 'Contact';
    Metadata.CustomMetadataValue f3 = new Metadata.CustomMetadataValue();
    f3.field = 'Is_Active__c'; f3.value = true;
    Metadata.CustomMetadataValue f4 = new Metadata.CustomMetadataValue();
    f4.field = 'Is_Header_Field__c'; f4.value = false;
    rec.values = new List<Metadata.CustomMetadataValue>{ f1, f2, f3, f4 };
    mdContainer.addMetadata(rec);
}


// ============================================================
// DEPLOY
// ============================================================
Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
System.debug('CMT deployment enqueued. Job ID: ' + jobId);
