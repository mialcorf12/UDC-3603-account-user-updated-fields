# SDD Design: UDC-3603 Dynamic Platform Events for Account & Contact

**Change Name:** `udc-3603-platform-events`  
**Status:** Design  
**Date:** 2026-07-07

---

## Technical Approach

Trigger → Handler → Service layering (one trigger per object). A single shared `FieldMappingService` evaluates old-vs-new field deltas via dynamic `SObject.get()`, injects fixed header keys unconditionally, serializes to JSON, and bulk-publishes Platform Events. CMT mappings are read once per transaction with **zero SOQL** via `Event_Field_Mapping__mdt.getAll()`, cached in a static Map. Existing UDC-3865 `Org_Event__e` flow is untouched — new logic is appended to the Account `after update` path.

---

## Architecture Decisions

| Decision | Chosen | Rationale |
|----------|--------|-----------|
| Handler method style | **Static** methods | Existing org convention; consistency |
| CMT retrieval | **`Event_Field_Mapping__mdt.getAll().values()`** | Zero SOQL; immune to 100-query limit under bulk |
| Null-change semantics | Compare `newVal != oldVal` on `Object` | JSON.serialize renders `"key":null` for null map value |
| Header fields | Always added regardless of change | User story requirement; identifier headers must appear in every payload |
| Failure handling | Inspect SaveResult[], log via System.debug, no throw/retry | Matches existing OrgEventPublisher pattern exactly |
| Contact context | Use Trigger.oldMap for true delta | Native Contact after-update trigger has old state available |

---

## Data Flow

```
Account after update ──▶ AccountTriggerHandler.handleAfterUpdate (EXISTING UDC-3865, untouched)
                    └──▶ AccountTriggerHandler.handleDynamicUpdate ──┐
Contact after update ──▶ ContactTriggerHandler.handleDynamicUpdate ──┤
                                                                      ▼
                                                FieldMappingService.publish{Account|Contact}Events
                                                                      │
                          FieldMappingSelectorCache.getMappings(obj) ─┤ (0 SOQL, static cache, getAll())
                                                                      ▼
                          per record: headers(always) + changed non-headers → Map<String,Object>
                                                                      ▼
                          JSON.serialize → Payload__c → collect events (bulk)
                                                                      ▼
                          EventBus.publish(List<...__e>) → check SaveResult[] → logFailures
```

---

## Component Design

### FieldMappingService
- `publishAccountEvents(List<Account> newRecords, Map<Id,Account> oldMap)` — static, with sharing
- `publishContactEvents(List<Contact> newRecords, Map<Id,Contact> oldMap)` — static, with sharing
- Per record: headers always included; non-header only when changed
- Publish gate: event fires only when ≥1 non-header mapped field changed
- Returns early if no CMT records exist

### FieldMappingSelectorCache
- Static Map<String, List<Event_Field_Mapping__mdt>> cache
- `getMappings(String objectApiName)` — returns filtered list for object + Is_Active__c=true
- Uses `Event_Field_Mapping__mdt.getAll()` — zero SOQL
- Lazy-init pattern; cache persists for tx lifetime

### ContactTrigger & ContactTriggerHandler
- Thin trigger delegates to static handler method
- Handler calls `FieldMappingService.publishContactEvents()`
- After-update context only; no after-insert

### AccountTrigger & AccountTriggerHandler (MODIFIED)
- Add `handleDynamicUpdate()` method (additive; existing methods untouched)
- Trigger calls both `handleAfterUpdate()` (UDC-3865) and `handleDynamicUpdate()` in isUpdate block

---

## Testing Strategy (Strict TDD)

| Layer | What | Approach |
|-------|------|----------|
| Unit — Cache | Filter by object + Is_Active__c; 0 extra SOQL on 2nd call | Limits.getQueries()==0; assert filtered size |
| Unit — Service | Headers always present; only changed non-headers included; null→`"key":null`; unmapped change→no event | Deserialize Payload__c; assert keys/values; Test.getEventBus().deliver() |
| Unit — Service bulk | 200 records single tx, Limits.getQueries()==0 | Bulk factory list |
| Integration — Account | Update mapped field → sfdc_account_updated__e; existing UDC-3865 still fires | Dual-path assertion; keep 5 legacy tests green |
| Integration — Contact | Update mapped field → sfdc_user_updated__e; unmapped→none | ContactTriggerHandlerTest |

Coverage target ≥85% per org policy.

---

## Payload Examples

### Account Before → After
Before: `{ "org_name": "Acme", "ulab_org_id": "ORG-001", "is_parent": false }`
After: `{ "Name": "Acme", "uLab_Acct_Number__c": "ORG-001", "Is_Parent__c": false }`

### Contact Before → After
Before: `{ "portal_id": "P-999", "first_name": "Jane", "last_name": "Doe", "email": "jane@example.com" }`
After: `{ "Portal_User_ID__c": "P-999", "FirstName": "Jane", "LastName": "Doe", "Email": "jane@example.com" }`

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| CMT deploy fails | Use fallback anonymous Apex script |
| Tests fail | Run locally; enforce 85% gate |
| Payload breaks integrations | Verify in sandbox before PR |
| Governor limits exceeded | Bulk test passes; 0 SOQL verified |

