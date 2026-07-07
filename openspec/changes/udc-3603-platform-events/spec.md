# SDD Spec: UDC-3603 Dynamic Platform Events for Account & Contact

**Change Name:** `udc-3603-platform-events`  
**Status:** Spec  
**Date:** 2026-07-07

---

## Purpose

Implement decoupled, dynamically configurable Custom Metadata Type (CMT) architectures to capture changes on Account and Contact records, publishing Platform Events with JSON payloads of only changed mapped fields and fixed headers.

---

## Functional Requirements

### SPEC-1: Event_Field_Mapping__mdt exists with correct fields and active records

The system MUST define the Custom Metadata Type `Event_Field_Mapping__mdt` and its records to drive dynamic field mapping without SOQL.

**Fields required:**
- `Salesforce_Field__c` (Text 80) — Salesforce API field name
- `JSON_Key__c` (Text 80) — Target JSON key
- `Object_API_Name__c` (Text 80) — 'Account' or 'Contact'
- `Is_Active__c` (Checkbox) — Toggle without deployment
- `Is_Header_Field__c` (Checkbox) — Always-include regardless of change

**Records:**
- 22 active Account records (including headers `uLab_Acct_Number__c`→`ulab_org_id`, `Id`→`account_sfdc_id`)
- 17 active Contact records (including headers `Portal_User_ID__c`→`ulab_user_id`, `Id`→`contact_sfdc_id`)

---

### SPEC-2: sfdc_account_updated__e fires on Account after-update

The system MUST publish `sfdc_account_updated__e` containing JSON payloads of changed mapped fields when Account records are updated.

**Scenario: Mapped Account Field Changes**
- GIVEN an Account record is updated
- AND at least 1 mapped field changes its value
- WHEN the after-update trigger executes
- THEN `sfdc_account_updated__e` is published with `Payload__c` containing the changed fields
- AND the fixed headers `ulab_org_id` and `account_sfdc_id` are ALWAYS present in the JSON payload

**Scenario: No Mapped Account Fields Change**
- GIVEN an Account record is updated
- AND NO mapped fields change their values
- WHEN the after-update trigger executes
- THEN NO `sfdc_account_updated__e` event is published

---

### SPEC-3: sfdc_user_updated__e fires on Contact after-update

The system MUST publish `sfdc_user_updated__e` containing JSON payloads of changed mapped fields when Contact records are updated.

**Scenario: Mapped Contact Field Changes**
- GIVEN a Contact record is updated
- AND at least 1 mapped field changes its value
- WHEN the after-update trigger executes
- THEN `sfdc_user_updated__e` is published with `Payload__c` containing the changed fields
- AND the fixed headers `ulab_user_id` and `contact_sfdc_id` are ALWAYS present in the JSON payload

**Scenario: No Mapped Contact Fields Change**
- GIVEN a Contact record is updated
- AND NO mapped fields change their values
- WHEN the after-update trigger executes
- THEN NO `sfdc_user_updated__e` event is published

---

### SPEC-4: Null value handling

The system MUST explicitly serialize null values in the JSON payload when a mapped field is cleared.

**Scenario: Tracked Field is Cleared to Null**
- GIVEN a tracked mapped field changes from a populated value to null
- WHEN the event payload is constructed
- THEN the JSON payload includes the corresponding key with a value of `null` (not an empty string)

---

### SPEC-5: Bulk safety (≥200 records)

The system MUST safely process bulk updates without exceeding SOQL or Heap limits.

**Scenario: Bulk Update with Field Changes**
- GIVEN 200 Account records are updated simultaneously with mapped field changes
- WHEN the dynamic field mapping service processes the records
- THEN all events are published successfully
- AND no SOQL limit or heap exceptions occur
- AND the CMT `Event_Field_Mapping__mdt` is accessed via `getAll()` resulting in exactly 0 SOQL queries consumed

---

### SPEC-6: PE publish failure handling

The system MUST log Platform Event publish failures without interrupting the user transaction.

**Scenario: EventBus Publish Returns Errors**
- GIVEN the dynamic field mapping service calls `EventBus.publish()`
- AND the returned `SaveResult` has `isSuccess=false`
- WHEN evaluating the result
- THEN the failure is logged
- AND the DML transaction is NOT rolled back

---

### SPEC-7: Additive integration with existing AccountTrigger (UDC-3865)

The system MUST integrate the new dynamic logic alongside existing Account after-update processes without disruption.

**Scenario: Account Update Invokes Both Paths**
- GIVEN an Account record is updated
- WHEN the Account after-update trigger executes
- THEN BOTH the existing UDC-3865 `OrgEventPublisher` path AND the new `FieldMappingService` path execute
- AND neither path breaks or interferes when the other runs

---

### SPEC-8: ContactTrigger exists and fires only on after-update

The system MUST route Contact updates to the handler using strict after-update contexts.

**Scenario: Contact Update Trigger Execution**
- GIVEN a Contact record is modified
- WHEN the trigger evaluates context
- THEN the `ContactTrigger` fires in the after-update context ONLY
- AND it successfully delegates to `ContactTriggerHandler.handleDynamicUpdate()` using a static method pattern

---

## Test Strategy

- FieldMappingSelectorCacheTest: cache returns correct filtered list; 0 SOQL on cache hit
- FieldMappingServiceTest: headers always present; changed-only non-headers; null→`"key":null`; bulk 200 safe
- ContactTriggerHandlerTest: mapped field change → event published; unmapped → no event
- AccountTriggerHandlerTest additions: dynamic path still fires; UDC-3865 path untouched

