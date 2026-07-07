# SDD Tasks: Refactor Event Field Mapping to Use Salesforce Field Names as Payload Keys

**Change Name:** `refactor-event-field-mapping`  
**Status:** Tasks  
**Date:** 2026-07-07  
**Total Tasks:** 12  
**Estimated Effort:** 2-3 hours  
**Risk Level:** Medium (metadata + code + tests)

---

## Task Breakdown by Work Unit

### Work Unit 1: Metadata Schema Changes
**Status:** Ready to Start  
**Effort:** 30 minutes  
**Dependencies:** None

#### Task 1.1: Remove JSON_Key__c Field Definition
- **What:** Delete `objects/Event_Field_Mapping__mdt/fields/JSON_Key__c.field-meta.xml`
- **How:**
  - File to delete: `force-app/main/default/objects/Event_Field_Mapping__mdt/fields/JSON_Key__c.field-meta.xml`
  - Verify no other files reference this field (grep: `JSON_Key__c`)
  - Commit: `git rm objects/Event_Field_Mapping__mdt/fields/JSON_Key__c.field-meta.xml`
- **Verification:** Metadata compiles; no errors in `sf project retrieve start`
- **AC:** Field removed; no references remain in codebase

#### Task 1.2: Update Event_Field_Mapping__mdt Object Description
- **What:** Update object metadata to document the new key strategy
- **How:**
  - Edit: `force-app/main/default/objects/Event_Field_Mapping__mdt/Event_Field_Mapping__mdt.object-meta.xml`
  - Add to description: "Uses Salesforce_Field__c as event payload keys (not JSON_Key__c)"
  - Commit: `git add -A && git commit -m "docs: update Event_Field_Mapping__mdt description"`
- **Verification:** Metadata compiles; description updated
- **AC:** Object description reflects new key strategy

---

### Work Unit 2: Apex Code Changes
**Status:** Ready to Start  
**Effort:** 45 minutes  
**Dependencies:** Work Unit 1 (metadata schema must be updated first)

#### Task 2.1: Refactor FieldMappingService.buildPayload()
- **What:** Update method to use `Salesforce_Field__c` instead of `JSON_Key__c` as map key
- **How:**
  - Edit: `force-app/main/default/classes/FieldMappingService.cls`
  - Locate: `buildPayload(SObject record, List<Event_Field_Mapping__mdt> mappings)` method
  - Change: `payloadMap.put(mapping.JSON_Key__c, fieldValue)` → `payloadMap.put(mapping.Salesforce_Field__c, fieldValue)`
  - Remove intermediate variable: `String jsonKey = mapping.JSON_Key__c;`
  - Update method JSDoc: document that payload uses Salesforce field names as keys
  - Commit: `git add -A && git commit -m "refactor: use Salesforce_Field__c as payload key in FieldMappingService"`
- **Verification:**
  - Code compiles without errors
  - All 28 existing tests in `FieldMappingServiceTest.cls` pass
  - Run: `sf apex run test --target-org Dev --test-level RunLocalTests`
- **AC:** Method uses `Salesforce_Field__c`; all tests pass

#### Task 2.2: Update FieldMappingService JSDoc & Comments
- **What:** Update class-level and method-level documentation
- **How:**
  - Edit: `force-app/main/default/classes/FieldMappingService.cls`
  - Update class JSDoc: mention new key strategy
  - Update `buildPayload()` JSDoc: document that payload map uses Salesforce field names
  - Update inline comments: remove references to `JSON_Key__c`
  - Commit: `git add -A && git commit -m "docs: update FieldMappingService comments to reflect new key strategy"`
- **Verification:** Comments are accurate and clear
- **AC:** All documentation updated; no outdated references

#### Task 2.3: Verify Apex Tests Pass
- **What:** Run full Apex test suite to ensure no regressions
- **How:**
  - Command: `sf apex run test --target-org Dev --code-coverage --detailed-coverage --wait 30`
  - Expected tests to pass:
    - FieldMappingServiceTest.cls (28 tests)
    - FieldMappingSelectorCacheTest.cls
    - AccountTriggerHandlerTest.cls
    - ContactTriggerHandlerTest.cls
    - OrgEventPublisherTest.cls
  - Verify coverage ≥ 85%
  - Commit: `git add -A && git commit -m "test: verify all Apex tests pass with new key strategy"` (if needed)
- **Verification:** Coverage ≥ 85%; all tests pass
- **AC:** All tests pass; coverage ≥ 85%; no regressions

---

### Work Unit 3: Custom Metadata Records — Deletions
**Status:** Ready to Start  
**Effort:** 20 minutes  
**Dependencies:** Work Unit 1 (schema must be updated first)

#### Task 3.1: Delete Obsolete Contact CMT Records
- **What:** Remove 5 Contact custom metadata records
- **How:**
  - Files to delete:
    - `customMetadata/Event_Field_Mapping__mdt.Contact_Activation_URL__c.md-meta.xml`
    - `customMetadata/Event_Field_Mapping__mdt.Contact_Mailing_Address_ID__c.md-meta.xml`
    - `customMetadata/Event_Field_Mapping__mdt.Contact_Sales_Informed_Agreement_Signed__c.md-meta.xml`
    - `customMetadata/Event_Field_Mapping__mdt.Contact_uLab_Systems_Account_Agreement_Signed__c.md-meta.xml`
    - `customMetadata/Event_Field_Mapping__mdt.Contact_Portal_User_ID.md-meta.xml` (old header)
  - Command: `git rm force-app/main/default/customMetadata/Event_Field_Mapping__mdt.Contact_*.md-meta.xml` (selective)
  - Commit: `git add -A && git commit -m "refactor: delete obsolete Contact CMT records (TOU fields + old headers)"`
- **Verification:** Files deleted; git diff shows removals only
- **AC:** 5 Contact records deleted; no errors

#### Task 3.2: Delete Obsolete Account CMT Records
- **What:** Remove 14 Account custom metadata records
- **How:**
  - Files to delete:
    - Billing address fields: `BillingCity`, `BillingCountry`, `BillingPostalCode`, `BillingState`, `BillingStreet`
    - Shipping address fields: `ShippingCity`, `ShippingCountry`, `ShippingPostalCode`, `ShippingState`, `ShippingStreet`
    - Old records: `Id`, `Phone`, `uLab_Acct_Number` (old header)
  - Command: `git rm force-app/main/default/customMetadata/Event_Field_Mapping__mdt.Account_*.md-meta.xml` (selective)
  - Commit: `git add -A && git commit -m "refactor: delete obsolete Account CMT records (address + old headers)"`
- **Verification:** Files deleted; git diff shows 14 record removals
- **AC:** 14 Account records deleted; no errors

---

### Work Unit 4: Custom Metadata Records — Creations (Account)
**Status:** Ready to Start  
**Effort:** 45 minutes  
**Dependencies:** Work Unit 1 (schema must support new records)

#### Task 4.1: Create 21 New Account CMT Records
- **What:** Create 21 Account custom metadata records with correct Salesforce field mappings
- **How:**
  - Create 21 XML files in `force-app/main/default/customMetadata/`
  - Naming pattern: `Event_Field_Mapping__mdt.Account_<FieldName>.md-meta.xml`
  - For each record, set:
    - `<label>Account_<FieldName></label>`
    - `<fullName>Account_<FieldName></fullName>`
    - `<Object_API_Name__c>Account</Object_API_Name__c>`
    - `<Salesforce_Field__c><field name></Salesforce_Field__c>`
    - `<Is_Active__c>true</Is_Active__c>`
    - `<Is_Header_Field__c>true</Is_Header_Field__c>` (only for 2 headers)
  - Headers (2): `AccountCaseSafeID__c`, `uLab_Acct_Number__c`
  - Non-headers (19): `Email__c`, `Account_Setup_Completed__c`, etc.
  - Reference: Spec document lists all 21 mappings with correct field names
  - Commit: `git add -A && git commit -m "refactor: create 21 new Account CMT records"`
- **Verification:**
  - All 21 XML files created
  - Each file has correct `Salesforce_Field__c` and `Is_Header_Field__c` values
  - No `JSON_Key__c` field present
  - Metadata compiles
- **AC:** 21 Account records created; all fields correct

#### Task 4.2: Create 20 New Contact CMT Records
- **What:** Create 20 Contact custom metadata records with correct Salesforce field mappings
- **How:**
  - Create 20 XML files in `force-app/main/default/customMetadata/`
  - Naming pattern: `Event_Field_Mapping__mdt.Contact_<FieldName>.md-meta.xml`
  - For each record, set same fields as Account records
  - Headers (2): `ContactCaseSafeID__c`, `Portal_User_ID__c`
  - Non-headers (18): `Email`, `FirstName`, `LastName`, etc.
  - Reference: Spec document lists all 20 mappings
  - Commit: `git add -A && git commit -m "refactor: create 20 new Contact CMT records"`
- **Verification:**
  - All 20 XML files created
  - Each file has correct `Salesforce_Field__c` and `Is_Header_Field__c` values
  - No `JSON_Key__c` field present
  - Metadata compiles
- **AC:** 20 Contact records created; all fields correct

---

### Work Unit 5: Deployment Manifest
**Status:** Ready to Start  
**Effort:** 15 minutes  
**Dependencies:** Work Units 1-4 (all metadata must be ready)

#### Task 5.1: Update package.xml with All Metadata
- **What:** Update `manifest/package.xml` to include all 41 CMT records and removed field
- **How:**
  - Edit: `manifest/package.xml`
  - Add section: `<types>` for `CustomMetadata` with 41 `<members>` (Account + Contact records)
  - Add section: `<types>` for `CustomField` with all 6 fields (including removal of `JSON_Key__c` reference)
  - Add section: `<types>` for `ApexClass` with all 12 classes
  - Add section: `<types>` for `ApexTrigger` with 2 triggers
  - Add section: `<types>` for `CustomObject` with 3 objects
  - Set version: `66.0`
  - Commit: `git add -A && git commit -m "refactor: update package.xml with 41 CMT records and metadata"`
- **Verification:**
  - XML is valid; no parsing errors
  - All 41 CMT members listed
  - Metadata types are correct
- **AC:** package.xml includes all 41 records; deployment-ready

#### Task 5.2: Verify package.xml Syntax
- **What:** Validate package.xml structure and deployability
- **How:**
  - Command: `sf project manifest list --target-org Dev` (verify metadata list)
  - Spot-check: 41 CMT members, 12 Apex classes, 2 triggers, 3 objects, 6 fields
  - Commit: (if needed) `git add -A && git commit -m "ci: verify package.xml syntax"`
- **Verification:** Manifest is valid; all members present
- **AC:** package.xml is deployable

---

### Work Unit 6: Deployment & Verification
**Status:** Blocked until Work Units 1-5 Complete  
**Effort:** 30 minutes  
**Dependencies:** All prior work units

#### Task 6.1: Deploy Metadata to Sandbox
- **What:** Deploy all changes to `ulab--audit` sandbox
- **How:**
  - Command: `sf project deploy start --target-org Dev --manifest manifest/package.xml --wait 30`
  - Alternative (if CLI fails): Use anonymous Apex script `jira/newMetadataFields.cls` with `sf apex run --file jira/newMetadataFields.cls --target-org Dev`
  - Verify deployment succeeds
  - Note: Deploy step removes `JSON_Key__c` field + adds new records automatically
- **Verification:** Deployment completes without errors
- **AC:** All metadata deployed to sandbox

#### Task 6.2: Run Apex Test Suite
- **What:** Verify all tests pass after deployment
- **How:**
  - Command: `sf apex run test --target-org Dev --code-coverage --detailed-coverage --wait 30`
  - Expected: All 28 tests pass; coverage ≥ 85%
  - Review coverage report for modified classes
- **Verification:** Coverage ≥ 85%; all tests pass
- **AC:** Tests pass; coverage acceptable

#### Task 6.3: Manual Sandbox Integration Test
- **What:** Verify event payload structure in sandbox
- **How:**
  - Login to `ulab--audit` sandbox
  - Create/Update an Account record (change a non-header field, e.g., Name)
  - Query Platform Event log: `SELECT Payload__c FROM sfdc_account_updated__e LIMIT 1`
  - Parse JSON payload; verify it contains Salesforce field names (e.g., `Name`, `uLab_Acct_Number__c`)
  - Verify header fields included in payload
  - Test edge case: Set a header to `Is_Active__c = false`, update Account, verify header NOT in payload
- **Verification:** Payload contains correct Salesforce field names; headers behave correctly
- **AC:** Integration test passes; payload structure correct

---

## Deployment Checklist

- [ ] Task 1.1: Remove `JSON_Key__c` field
- [ ] Task 1.2: Update object description
- [ ] Task 2.1: Refactor `buildPayload()` method
- [ ] Task 2.2: Update JSDoc & comments
- [ ] Task 2.3: Verify tests pass (85%+ coverage)
- [ ] Task 3.1: Delete 5 Contact records
- [ ] Task 3.2: Delete 14 Account records
- [ ] Task 4.1: Create 21 Account records
- [ ] Task 4.2: Create 20 Contact records
- [ ] Task 5.1: Update package.xml
- [ ] Task 5.2: Verify manifest syntax
- [ ] Task 6.1: Deploy to sandbox
- [ ] Task 6.2: Run test suite (85%+ coverage)
- [ ] Task 6.3: Manual integration test

---

## PR Strategy & Delivery

### Chained PR Plan (3 PRs)

**PR #1: Metadata + Code Refactor**
- Include: Field removal, object description, `buildPayload()` refactor, JSDoc updates
- Size: ~150 lines
- Tests: All existing tests pass; coverage ≥ 85%
- Gate: Code review approval before merge

**PR #2: CMT Record Updates**
- Include: 19 record deletions + 41 record creations
- Size: ~1200 lines (XML metadata)
- Tests: Metadata compiles; no errors
- Gate: Metadata validation before merge

**PR #3: Manifest & Deployment**
- Include: package.xml updates, deployment verification
- Size: ~200 lines
- Tests: Integration test passes; payload structure verified
- Gate: Sandbox verification before merge

### Review Workload Forecast
- **Total Changed Lines:** ~1550 (mostly CMT XML, not code)
- **Recommendation:** Chained PRs (to keep each PR ≤ 400-500 lines of substantive code)
- **Risk Level:** Medium (metadata changes; no functional logic changes; existing tests pass)
- **Timeline:** 2-3 hours implementation + 1-2 hours review

---

## Risk & Mitigation

| Risk | Mitigation |
|---|---|
| CMT deployment fails | Use fallback anonymous Apex script; verify deployment in sandbox before PR |
| Tests fail | Run tests locally before commit; verify coverage ≥ 85% |
| Header filtering broken | Code review validates no changes to cache/trigger logic |
| Integration test fails | Debug payload JSON; verify field names match Salesforce names |
| Rollback needed | Revert commit; prior code uses `JSON_Key__c` automatically |

---

## Sign-Off Gate

Before proceeding to `sdd-apply`, confirm:
- [ ] All 12 tasks estimated and understood
- [ ] Chained PR strategy approved (3 PRs, ~1550 lines total)
- [ ] Risk mitigation strategies confirmed
- [ ] Sandbox deployment & testing plan acceptable
- [ ] Coverage gate (85%+) confirmed

