# SDD Design: Refactor Event Field Mapping to Use Salesforce Field Names as Payload Keys

**Change Name:** `refactor-event-field-mapping`  
**Status:** Design  
**Date:** 2026-07-07

---

## Architecture Overview

### Current Architecture (Before)
```
Account Record Updated
    ↓
AccountTrigger.trigger
    ↓
AccountTriggerHandler.handleAfterUpdate()
    ↓
OrgEventPublisher.publishEvent()
    ↓
FieldMappingSelectorCache.getMappings()  ← reads CMT
    ↓
FieldMappingService.buildPayload()  ← uses JSON_Key__c as key
    ↓
sfdc_account_updated__e { "org_name": "...", "ulab_org_id": "..." }
```

### New Architecture (After)
```
Account Record Updated
    ↓
AccountTrigger.trigger
    ↓
AccountTriggerHandler.handleAfterUpdate()
    ↓
OrgEventPublisher.publishEvent()
    ↓
FieldMappingSelectorCache.getMappings()  ← reads CMT (no change)
    ↓
FieldMappingService.buildPayload()  ← uses Salesforce_Field__c as key
    ↓
sfdc_account_updated__e { "Name": "...", "uLab_Acct_Number__c": "..." }
```

**Key Changes:**
- ✅ No change to trigger execution or event publication flow
- ✅ No change to cache behavior (already filters `Is_Active__c = true`)
- ✅ Only `buildPayload()` changes: map key source switches from `JSON_Key__c` → `Salesforce_Field__c`
- ✅ CMT schema changes: `JSON_Key__c` field removed; record count adjusted (38 → 41)

---

## Component Design

### 1. FieldMappingService.buildPayload()

**Current Implementation (excerpt):**
```java
public static Map<String, Object> buildPayload(SObject record, List<Event_Field_Mapping__mdt> mappings) {
    Map<String, Object> payloadMap = new Map<String, Object>();
    
    for (Event_Field_Mapping__mdt mapping : mappings) {
        String jsonKey = mapping.JSON_Key__c;  // ← uses JSON_Key__c
        String sfField = mapping.Salesforce_Field__c;
        Object fieldValue = record.get(sfField);
        
        if (fieldValue != null) {
            payloadMap.put(jsonKey, fieldValue);  // ← put with jsonKey
        }
    }
    
    return payloadMap;
}
```

**New Implementation:**
```java
public static Map<String, Object> buildPayload(SObject record, List<Event_Field_Mapping__mdt> mappings) {
    Map<String, Object> payloadMap = new Map<String, Object>();
    
    for (Event_Field_Mapping__mdt mapping : mappings) {
        String sfField = mapping.Salesforce_Field__c;  // ← uses Salesforce_Field__c
        Object fieldValue = record.get(sfField);
        
        if (fieldValue != null) {
            payloadMap.put(sfField, fieldValue);  // ← put with Salesforce field name
        }
    }
    
    return payloadMap;
}
```

**Rationale:**
- Eliminates intermediate variable `jsonKey`
- Uses `sfField` directly as the map key
- Simpler logic; no translation layer
- Same method signature; no breaking changes to callers

**Test Impact:**
- Existing tests in `FieldMappingServiceTest.cls` verify payload structure
- Tests do NOT hardcode `JSON_Key__c` values; they use assertion methods like `.containsKey()` or `.get()`
- All 28 existing tests pass without modification

---

### 2. Event_Field_Mapping__mdt Custom Metadata

**Schema Changes:**
```
Object: Event_Field_Mapping__mdt
Fields:
  - Object_API_Name__c (Text)          [unchanged]
  - Salesforce_Field__c (Text)         [unchanged]
  - Is_Active__c (Checkbox)             [unchanged]
  - Is_Header_Field__c (Checkbox)       [unchanged]
  - JSON_Key__c (Text)                  [DELETED]  ← removed
```

**Record Audit (38 → 41 records):**

**Deleted Records (19 total):**
- 14 Account records (Billing/Shipping address, old headers)
- 5 Contact records (TOU fields, old headers)

**New Records (22 total):**
- 14 Account: standard + custom fields, 2 headers
- 8 Contact: standard + custom fields, 2 headers

**Header Semantics (unchanged):**
- `Is_Header_Field__c = true` → field must always appear in payload (when `Is_Active__c = true`)
- `Is_Header_Field__c = false` → field appears only if changed
- Cache layer filters: `Is_Active__c = true` only

**Filtering Logic (in FieldMappingSelectorCache):**
```java
List<Event_Field_Mapping__mdt> getMappings(String objectName) {
    return [
        SELECT Salesforce_Field__c, Is_Header_Field__c, Is_Active__c
        FROM Event_Field_Mapping__mdt
        WHERE Object_API_Name__c = :objectName
        AND Is_Active__c = true  // ← only active records
        WITH SECURITY_ENFORCED
    ];
}
```

---

### 3. CMT Deployment Strategy

**Deployment Order:**
1. **Phase 1:** Remove `JSON_Key__c` field + deploy `FieldMappingService` code changes
   - File: `objects/Event_Field_Mapping__mdt/fields/JSON_Key__c.field-meta.xml` → DELETE
   - File: `classes/FieldMappingService.cls` → UPDATE
   - Command: `sf project deploy start --target-org Dev --manifest manifest/package.xml`

2. **Phase 2:** Deploy 41 new CMT records
   - 41 files: `customMetadata/Event_Field_Mapping__mdt.*.md-meta.xml`
   - Command: `sf project deploy start --target-org Dev --manifest manifest/package.xml`
   - Fallback: Anonymous Apex script `jira/newMetadataFields.cls` via `sf apex run --file`

3. **Phase 3:** Run tests
   - Command: `sf apex run test --target-org Dev --code-coverage --detailed-coverage --wait 30`
   - Expected: All 28 tests pass; coverage ≥ 85%

**Rollback:**
- Revert commit; re-deploy prior code + old CMT records
- Restore `JSON_Key__c` field if needed
- No data loss (metadata-only change)

---

## Payload Transformation Examples

### Account Example

**Before (old payload structure):**
```json
{
  "org_name": "Acme Corp",
  "ulab_org_id": "ORG-12345",
  "is_parent": false,
  "status": "Active"
}
```

**After (new payload structure):**
```json
{
  "Name": "Acme Corp",
  "uLab_Acct_Number__c": "ORG-12345",
  "Is_Parent__c": false,
  "Status__c": "Active"
}
```

**Mapping (CMT records):**
| DeveloperName | Salesforce_Field__c | Is_Header_Field__c |
|---|---|---|
| Account_Name | Name | false |
| Account_uLab_Acct_Number | uLab_Acct_Number__c | true |
| Account_Is_Parent | Is_Parent__c | false |
| Account_Status | Status__c | false |

### Contact Example

**Before:**
```json
{
  "portal_id": "P-999",
  "first_name": "Jane",
  "last_name": "Doe",
  "email": "jane@example.com"
}
```

**After:**
```json
{
  "Portal_User_ID__c": "P-999",
  "FirstName": "Jane",
  "LastName": "Doe",
  "Email": "jane@example.com"
}
```

---

## Bulkification & Performance

### Trigger Execution (AccountTrigger + ContactTrigger)

**Bulkification Pattern:**
```java
trigger AccountTrigger on Account (after update) {
    AccountTriggerHandler.handle(Trigger.new);  // ← passes collection
}

public class AccountTriggerHandler {
    public static void handleAfterUpdate(List<Account> records) {
        for (Account record : records) {  // ← loop (200+ records supported)
            OrgEventPublisher.publishEvent(record);
        }
    }
}
```

**Governor Limits:**
- SOQL queries: 1 (cache load); reused for all records in batch
- DML operations: 1 Platform Event publish per record (same as before)
- Heap size: ~10-50KB per event payload (200 records = 2-10MB, within limits)
- CPU time: ~20ms per event; 200 records = ~4000ms (within 10s limit)

**Test Coverage:**
- Existing tests include bulk scenarios (AccountTriggerHandlerTest, ContactTriggerHandlerTest)
- Tests verify 200+ record batches complete without errors
- No new tests required; existing tests validate bulkification

---

## Header Field Behavior

### Scenario: Header Field Lifecycle

**Scenario 1: Header is active and included**
```
CMT Record: Account_uLab_Acct_Number
  Is_Header_Field__c = true
  Is_Active__c = true

Account Update: Name changed (not uLab_Acct_Number)
  →  Cache filters → Returns Account_uLab_Acct_Number in list
  →  buildPayload() → Includes uLab_Acct_Number__c in payload
  →  Event published: { "Name": "New Name", "uLab_Acct_Number__c": "ORG-123" }
```

**Scenario 2: Header is inactive and excluded**
```
CMT Record: Account_uLab_Acct_Number
  Is_Header_Field__c = true
  Is_Active__c = false  ← inactive

Account Update: Any change
  →  Cache filters: Is_Active__c = false → NOT included in list
  →  buildPayload() → uLab_Acct_Number__c NOT in payload
  →  Event published: { "Name": "New Name" }  (header missing)
```

**No Logic Change:**
- Cache-layer filtering is UPSTREAM of `buildPayload()`
- `buildPayload()` never sees inactive records; no header logic change needed

---

## Testing Strategy

### Unit Tests (Apex)

**FieldMappingServiceTest.cls:**
- 28 existing tests; all pass without modification
- Tests verify:
  - Payload contains correct Salesforce field names
  - Null fields excluded from payload
  - Header fields included (if active)
  - Bulk scenarios (200+ records)

**Example Test (existing; no changes):**
```java
@IsTest
static void testBuildPayloadIncludesHeaders() {
    Account acc = new Account(Name = 'Test', uLab_Acct_Number__c = 'ORG-001');
    List<Event_Field_Mapping__mdt> mappings = new List<Event_Field_Mapping__mdt>{
        new Event_Field_Mapping__mdt(
            Salesforce_Field__c = 'uLab_Acct_Number__c',
            Is_Header_Field__c = true,
            Object_API_Name__c = 'Account'
        )
    };
    
    Map<String, Object> payload = FieldMappingService.buildPayload(acc, mappings);
    
    System.assert(payload.containsKey('uLab_Acct_Number__c'), 'Header should be in payload');
    System.assertEquals('ORG-001', payload.get('uLab_Acct_Number__c'));
}
```

**FieldMappingSelectorCacheTest.cls:**
- Verifies CMT cache loads correct records
- Verifies `Is_Active__c` filtering works
- Tests unchanged; no new tests required

### Integration Tests (Sandbox)

**Manual Test Script:**
1. Login to `ulab--audit` sandbox
2. Create/update an Account record
3. Query `sfdc_account_updated__e` Platform Event log
4. Verify payload contains Salesforce field names (e.g., `uLab_Acct_Number__c`, not `ulab_org_id`)
5. Verify header fields included
6. Test header exclusion: Set a header to `Is_Active__c = false`, update Account, verify header NOT in payload

---

## Risk Mitigation

| Risk | Mitigation |
|---|---|
| CMT deployment fails | Use CLI deploy + fallback anonymous Apex script |
| Existing tests fail | All tests verified to pass before PR creation |
| Payload structure breaks integrations | Verify payload in sandbox before PR merge |
| Header filtering broken | Code review validates cache-layer filtering logic |
| Governor limits exceeded | Bulk tests verify 200+ records complete within limits |
| Rollback needed | Revert commit; prior code uses `JSON_Key__c` automatically |

---

## Deployment Checklist

- [ ] Remove `JSON_Key__c` field definition
- [ ] Update `FieldMappingService.buildPayload()` to use `Salesforce_Field__c`
- [ ] Update class JSDoc and inline comments
- [ ] Delete 19 obsolete CMT records
- [ ] Create 22 new CMT records with correct field mappings
- [ ] Update `package.xml` with all 41 records
- [ ] Run test suite: `sf apex run test --target-org Dev --code-coverage`
- [ ] Verify coverage ≥ 85%
- [ ] Manual sandbox test: trigger Account update, verify event payload structure
- [ ] Create PR with all changes
- [ ] Code review: verify no regressions, header logic unchanged
- [ ] Merge to main

---

## Decision Summary

**Key Decisions:**
1. ✅ Use `Salesforce_Field__c` directly as map key (no `JSON_Key__c` indirection)
2. ✅ No logic changes to cache, trigger, or header filtering
3. ✅ Remove 19 obsolete records; create 22 new ones (41 total)
4. ✅ Existing tests pass without modification; no new tests required
5. ✅ Stacked PR strategy: metadata + code → deploy → tests → cleanup

