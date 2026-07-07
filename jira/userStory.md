# User Story: Implement Dynamic Platform Events for Account and Contact Changes

As a Platform Architect / System Developer

I want to implement two Platform Events ( `sfdc_account_updated` and `sfdc_contact_updated` ) that fire during the after update context of Accounts and Contacts

So that external systems are notified only about modified fields that have been dynamically mapped.


## Description & Technical Context

We need a decoupled and highly configurable architecture to capture changes on Account and Contact records. Instead of hardcoding the field comparison logic, a dynamic configuration mechanism (such as a Custom Metadata Type, e.g., `Event_Field_Mapping__mdt` ) must be used. This will allow administrators to add, remove, or modify tracked Salesforce fields and define their corresponding JSON keys without changing Apex code.


## Acceptance Criteria

### 1. Dynamic Field Mapping Configuration (Mapping Table)

- A configuration mechanism must exist to easily activate, deactivate, or modify the mapped fields.
- The mapping table structure and its initial data load must contain relationships: 
 | 	Campo Salesforce (API Name)	 | 	Campo Destino (JSON Key)	 | 	Objeto	 | 
 | 	uLab_Acct_Number__c	 | 	org_id	 | 	Account	 | 
 | 	Id	 | 	org_sfdc_id	 | 	Account	 | 
 | 	Is_Parent__c	 | 	is_parent	 | 	Account	 | 
 | 	Name	 | 	org_name	 | 	Account	 | 
 | 	Type	 | 	org_type	 | 	Account	 | 
 | 	Account_Status__c	 | 	org_status	 | 	Account	 | 
 | 	Phone	 | 	phone	 | 	Account	 | 
 | 	ShippingAddressID__c	 | 	shipping_address_id	 | 	Account	 | 
 | 	ShippingStreet	 | 	shipping_address_1	 | 	Account	 | 
 | 	ShippingCity	 | 	shipping_city	 | 	Account	 | 
 | 	ShippingCountry	 | 	shipping_country	 | 	Account	 | 
 | 	ShippingState	 | 	shipping_region	 | 	Account	 | 
 | 	ShippingPostalCode	 | 	shipping_zip	 | 	Account	 | 
 | 	BillingAddressID__c	 | 	billing_address_id	 | 	Account	 | 
 | 	BillingStreet	 | 	billing_address_1	 | 	Account	 | 
 | 	BillingCity	 | 	billing_city	 | 	Account	 | 
 | 	BillingCountry	 | 	billing_country	 | 	Account	 | 
 | 	BillingState	 | 	billing_region	 | 	Account	 | 
 | 	BillingPostalCode	 | 	billing_zip	 | 	Account	 | 
 | 	Signature_Required__c	 | 	signature_required	 | 	Account	 | 
 | 	Out_of_Service_Area__c	 | 	out_of_service_area	 | 	Account	 | 
 | 	Portal_User_ID__c	 | 	user_id	 | 	Contact	 | 
  | 	Id	 | 	user_sfdc_id	 | 	Account	 | 
 | 	FirstName	 | 	first_name	 | 	Contact	 | 
 | 	LastName	 | 	last_name	 | 	Contact	 | 
 | 	Email	 | 	email	 | 	Contact	 | 
 | 	Phone	 | 	phone	 | 	Contact	 | 
 | 	Company_User_Type__c	 | 	user_type	 | 	Contact	 | 
 | 	Contact_Role__c	 | 	role	 | 	Contact	 | 
 | 	Mailing_Address_ID__c	 | 	mailing_address_id	 | 	Contact	 | 
 | 	MailingStreet	 | 	mailing_address_1	 | 	Contact	 | 
 | 	MailingCity	 | 	mailing_city	 | 	Contact	 | 
 | 	MailingCountry	 | 	mailing_country	 | 	Contact	 | 
 | 	MailingState	 | 	mailing_state	 | 	Contact	 | 
 | 	MailingPostalCode	 | 	mailing_zipcode	 | 	Contact	 | 
 | 	uLab_Systems_Account_Agreement_Signed__c	 | 	tou_accepted_flag	 | 	Contact	 | 
 | 	Sales_Informed_Agreement_Signed__c	 | 	tou_updated_ts	 | 	Contact	 | 
 | 	Activation_URL__c	 | 	activation_url	 | 	Contact	 | 
 
 # 2. Trigger Logic and Firing Conditions

The event logic must execute strictly within the after update context of the Account and Contact trigger handlers.

The Platform Event should only be published if at least one of the fields defined in the mapping table for that object has changed its value (Trigger.oldMap vs Trigger.newMap).

# 3. Dynamic Payload Construction

The final JSON payload contained within the Platform Event must be built dynamically.

It should include only the fields from the mapping table that were actually modified during the update transaction.

When constructing the JSON object, the JSON key must be the value configured under "Target Field (JSON Key)", and the JSON value must be the live Salesforce record data at the moment of the update.

## Platform Event Specifications

### 1. Platform Event: sfdc_account_updated

- **Trigger**: After Update on Account  
- **Fixed Header Keys**:  
  - ulab_org_id (always mapped from Account.ulLab_Acct_Number__c)  
  - account_sfdc_id (always mapped from Account.Id)  

These must be included in every event payload regardless of whether they changed.
Expected Payload Structure (JSON format stored in a Long Text Area field):

```json
{
  "ulab_org_id": "<ulLab_Acct_Number__c>",
  "account_sfdc_id": "<Id>",
  "org_name": "Updated Company Name LLC",
  "phone": "+15551234567"
}
```

*(Note: org_name and phone are just examples of what the payload looks like when only those two mapped fields are modified).*


## 2. Platform Event: sfdc_user_updated

- **Trigger**: After Update on Contact.
- **Fixed Header Keys**: 
  - ulab_user_id (always mapped from Contact.Portal_User_ID__c)
  - contact_sfdc_id (always mapped from Contact.Id)  
  - These must be included in every event payload regardless of whether they changed.
- Expected Payload Structure (JSON format stored in a Long Text Area field)

```json
{
  "user": "<乏",
  "ulab_user_id": "<Portal_User_ID__c>",
  "contact_sfdc_id": "<Id>",
  "email": "new.email@example.com",
  "user_type": "Admin"
}
```

*(Note: email and user_type are just examples of what the payload looks like when only those two mapped fields are modified).*


### Developer & Architecture Notes

#### Bulkification & Performance:
Ensure that the Custom Metadata Type records are queried once per execution context and cached in memory to safeguard Governor Limits during bulk processing.

#### Handling Nulls:
If a tracked field changes from a value to null or empty string, the JSON payload must explicitly reflect this change (e.g., `"org_status": null` or `"org_status": ""`).

#### Key Fields: 
The fields that act as identifiers (uLab_Acct_Number__c, org_sfdc_id, user_sfdc_id and Portal_User_ID__c) must always be included in the header of the corresponding object's payload, regardless of whether they changed or not in the current transaction.
  