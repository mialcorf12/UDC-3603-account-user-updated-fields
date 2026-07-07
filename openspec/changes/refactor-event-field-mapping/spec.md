# SDD Spec: Refactor Event Field Mapping to Use Salesforce Field Names as Payload Keys

**Change Name:** `refactor-event-field-mapping`  
**Status:** Spec  
**Date:** 2026-07-07

---

## Functional Requirements

### FR1: Remove JSON_Key__c Field from Custom Metadata
- Delete the `JSON_Key__c` custom field from the `Event_Field_Mapping__mdt` object
- Ensure no dependent flows, formulas, or validation rules reference this field
- Update object description to reflect the new key strategy

**Acceptance Criteria:**
- ✅ Field definition removed; metadata compiles without errors
- ✅ No references to `JSON_Key__c` remain in codebase (Apex, Flow, etc.)
- ✅ Existing CMT records deploy without errors

---

### FR2: Update FieldMappingService to Use Salesforce Field Names as Keys
- Modify `FieldMappingService.buildPayload()` method to use `mapping.Salesforce_Field__c` as the map key instead of `mapping.JSON_Key__c`
- Ensure the method signature and return type remain unchanged
- Update JSDoc to document the new key strategy

**Method Signature (unchanged):**
```java
public static Map<String, Object> buildPayload(SObject record, List<Event_Field_Mapping__mdt> mappings)
```

**Behavior Change:**
- **Before:** `payloadMap.put(mapping.JSON_Key__c, fieldValue);`
- **After:** `payloadMap.put(mapping.Salesforce_Field__c, fieldValue);`

**Acceptance Criteria:**
- ✅ Method uses `Salesforce_Field__c` for all map keys
- ✅ Header fields are included correctly (only when `Is_Active__c = true`)
- ✅ Null values are handled correctly
- ✅ All existing unit tests pass without modification
- ✅ JSDoc comments updated and accurate

---

### FR3: Audit and Refresh Custom Metadata Records
- Remove 19 obsolete CMT records (5 Contact + 14 Account)
- Create 22 new CMT records (8 Contact + 14 Account) with correct field mappings
- Final CMT count: 41 records (20 Contact + 21 Account)

**Records to Delete:**
- **Contact (5):** 
  - `Contact_Activation_URL__c`
  - `Contact_Mailing_Address_ID__c`
  - `Contact_Sales_Informed_Agreement_Signed__c`
  - `Contact_uLab_Systems_Account_Agreement_Signed__c`
  - `Contact_Portal_User_ID` (old header)

- **Account (14):**
  - `Account_BillingCity`, `Account_BillingCountry`, `Account_BillingPostalCode`, `Account_BillingState`, `Account_BillingStreet`
  - `Account_ShippingCity`, `Account_ShippingCountry`, `Account_ShippingPostalCode`, `Account_ShippingState`, `Account_ShippingStreet`
  - `Account_Id`
  - `Account_Phone`
  - `Account_uLab_Acct_Number` (old header)

**Records to Create (22 total):**

**Account (14):**
1. `Account_AccountCaseSafeID` → `AccountCaseSafeID__c` (header, active)
2. `Account_Account_Email` → `Email__c` (active)
3. `Account_Account_Setup_Completed` → `Account_Setup_Completed__c` (active)
4. `Account_Acct_Owner_Identified` → `Acct_Owner_Identified__c` (active)
5. `Account_Area_Sales_Director` → `Area_Sales_Director__c` (active)
6. `Account_Company_Variant` → `Company_Variant__c` (active)
7. `Account_Custom_Box_Active` → `Custom_Box_Active__c` (active)
8. `Account_Development_Specialist` → `Development_Specialist__c` (active)
9. `Account_Integration_Specialist` → `Integration_Specialist__c` (active)
10. `Account_Invoice_Start_Date` → `Invoice_Start_Date__c` (active)
11. `Account_Is_Parent` → `Is_Parent__c` (active)
12. `Account_Name` → `Name` (active)
13. `Account_Parent_Acct` → `ParentId` (active)
14. `Account_Process_Type` → `Process_Type__c` (active)
15. `Account_Signature_Required` → `Signature_Required__c` (active)
16. `Account_Special_Handling` → `Special_Handling__c` (active)
17. `Account_Status` → `Status__c` (active)
18. `Account_Type` → `Type` (active)
19. `Account_uAssist_Customer` → `uAssist_Customer__c` (active)
20. `Account_Out_of_Service_Area` → `Out_of_Service_Area__c` (active)
21. `Account_uLab_Acct_Number` → `uLab_Acct_Number__c` (header, active)

**Contact (8):**
1. `Contact_Communication_Preference` → `Communication_Preference__c` (active)
2. `Contact_Company_User_Type` → `Company_User_Type__c` (active)
3. `Contact_ContactCaseSafeID` → `ContactCaseSafeID__c` (header, active)
4. `Contact_Contact_Role` → `Contact_Role__c` (active)
5. `Contact_Email` → `Email` (active)
6. `Contact_FirstName` → `FirstName` (active)
7. `Contact_LastName` → `LastName` (active)
8. `Contact_MobilePhone` → `MobilePhone` (active)
9. `Contact_Phone` → `Phone` (active)
10. `Contact_Portal_User_ID` → `Portal_User_ID__c` (header, active)
11. `Contact_Preferred_Language` → `Preferred_Language__c` (active)
12. `Contact_Salutation` → `Salutation` (active)
13. `Contact_Status` → `Status__c` (active)
14. `Contact_Title` → `Title` (active)
15. `Contact_Username` → `Username__c` (active)
16. `Contact_MailingCity` → `MailingCity` (active)
17. `Contact_MailingCountry` → `MailingCountry` (active)
18. `Contact_MailingPostalCode` → `MailingPostalCode` (active)
19. `Contact_MailingState` → `MailingState` (active)
20. `Contact_MailingStreet` → `MailingStreet` (active)

**Acceptance Criteria:**
- ✅ 19 obsolete records deleted; no deployment errors
- ✅ 22 new records created with correct `Salesforce_Field__c` values and no `JSON_Key__c` values
- ✅ All 41 records have correct `Object_API_Name__c`, `Is_Active__c`, and `Is_Header_Field__c` values
- ✅ Header records correctly flagged (4 total: 2 Account headers + 2 Contact headers)
- ✅ All records deploy successfully to sandbox

---

### FR4: Update package.xml Manifest
- Add all 41 CMT records to `package.xml`
- Add all modified Apex classes and triggers
- Remove `JSON_Key__c` field from the manifest
- Ensure manifest structure is correct for deployment

**Acceptance Criteria:**
- ✅ `package.xml` includes all 41 CMT members
- ✅ All Apex classes, triggers, and custom fields listed
- ✅ Manifest is valid XML; deployment succeeds

---

### FR5: Update Documentation and Comments
- Update `FieldMappingService` class JSDoc to document the new key strategy
- Update method-level comments for `buildPayload()`
- Update `Event_Field_Mapping__mdt` object description

**Acceptance Criteria:**
- ✅ JSDoc accurately reflects new key strategy
- ✅ Comments mention `Salesforce_Field__c` (not `JSON_Key__c`)
- ✅ No outdated references remain

---

## Non-Functional Requirements

### NFR1: Test Coverage
- All modified classes must maintain ≥ 85% code coverage
- No new test classes required; existing tests must pass without modification
- Test suite must run in < 30 seconds

**Acceptance Criteria:**
- ✅ `FieldMappingServiceTest.cls` passes (28 tests)
- ✅ `FieldMappingSelectorCacheTest.cls` passes
- ✅ All other Apex tests pass
- ✅ Coverage ≥ 85% on modified classes

### NFR2: Performance
- Event publish must complete in < 200ms per record
- No additional SOQL queries introduced
- Payload generation must be bulkified (supports 200+ records per batch)

**Acceptance Criteria:**
- ✅ No new SOQL in `buildPayload()`
- ✅ Bulk test with 200+ records completes successfully
- ✅ Governor limits not exceeded

### NFR3: Backward Compatibility
- Event publish logic must continue to work for existing downstream consumers
- Payload schema changes only; no breaking changes to event structure
- Header behavior must remain unchanged

**Acceptance Criteria:**
- ✅ Payload still contains all expected fields
- ✅ Header fields included when `Is_Active__c = true`
- ✅ No functional regressions in trigger behavior

---

## Data Migration

No data migration required. This is a metadata-only change:
- Apex code updated to use `Salesforce_Field__c` instead of `JSON_Key__c`
- CMT records refreshed; old records deleted, new records created
- No production data affected

---

## Testing Strategy

### Unit Tests (Apex)
- Existing test suite runs without modification
- `FieldMappingServiceTest.cls` verifies `buildPayload()` output structure
- `FieldMappingSelectorCacheTest.cls` verifies CMT cache behavior

### Integration Tests (Sandbox)
- Trigger an Account update on `ulab--audit` sandbox
- Verify `sfdc_account_updated__e` Platform Event payload contains Salesforce field names as keys
- Verify header fields are included in payload

### Acceptance Criteria
- ✅ All 28 existing tests pass
- ✅ Code coverage ≥ 85%
- ✅ Sandbox integration test passes
- ✅ No regressions in event publish behavior

---

## Deployment Plan

### Deployment Steps (in order)
1. Deploy `JSON_Key__c` field removal (via `package.xml`)
2. Deploy `FieldMappingService.cls` code changes
3. Deploy 41 new CMT records (via `package.xml` or anonymous Apex)
4. Run test suite in sandbox
5. Verify event payload in sandbox
6. Create PR and merge to main

### Rollback Plan
- Revert `FieldMappingService.cls` to use `JSON_Key__c` (prior commit)
- Re-deploy old CMT records from prior commit
- Re-add `JSON_Key__c` field if needed

---

## Scenarios & Edge Cases

### Scenario 1: Header Field with Is_Active__c = false
- **Given:** A header field has `Is_Active__c = false`
- **When:** Event is published
- **Then:** The header field is NOT included in payload (filtered at cache layer)
- **Reasoning:** `FieldMappingSelectorCache.getMappings()` filters on `Is_Active__c` (line 24)

### Scenario 2: Non-Header Field with Is_Active__c = false
- **Given:** A non-header field has `Is_Active__c = false`
- **When:** Event is published
- **Then:** The field is NOT included in payload (filtered at cache layer)
- **Reasoning:** Same as above; cache-layer filtering is upstream

### Scenario 3: Changed Field Not in CMT Mapping
- **Given:** Account.Email changes, but no CMT record for Account_Email
- **When:** Event is published
- **Then:** Email is NOT included in payload (not in mappings list)
- **Reasoning:** `buildPayload()` only includes fields in the CMT mapping list

### Scenario 4: Bulk Update (200+ Accounts)
- **Given:** 200 Accounts are updated via bulk API
- **When:** Trigger fires for each record
- **Then:** Each record publishes an event with correct payload structure
- **Reasoning:** Trigger is bulkified; no governor limit violations

---

## Success Metrics

- ✅ Zero production incidents post-deployment
- ✅ All tests pass; coverage ≥ 85%
- ✅ Event payloads contain Salesforce field names as keys
- ✅ No downstream integration failures
- ✅ Header field behavior unchanged

