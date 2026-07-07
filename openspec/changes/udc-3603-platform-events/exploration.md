# SDD Exploration: UDC-3603 Dynamic Platform Events for Account & Contact

**Change Name:** `udc-3603-platform-events`  
**Status:** Exploration (Completed)  
**Date:** 2026-07-07

---

## Current State

The org (`ulab--audit`, alias `Dev`) already has a production implementation for UDC-3865 that covers Account onboarding-status events using a hardcoded field list + `Org_Event__e`. The NEW work (UDC-3603) replaces/extends the Account event with a **CMT-driven dynamic field mapping** approach AND adds a brand-new Contact event.

### Existing Artifacts (Already in Org)
- `AccountTrigger` — after insert + after update; delegates to `AccountTriggerHandler`
- `AccountTriggerHandler` — filters on `UDC_Onboarding__c` + `Onboarding_Status__c` transition; calls `OrgEventPublisher.publishEvents()`
- `OrgEventPublisher` — publishes `Org_Event__e`; hardcoded field list; Contact query (1 SOQL)
- `OrgEventPublisherConfig` — static constants; `TRACKED_ACCOUNT_FIELDS`, `TRACKED_CONTACT_FIELDS`
- `OrgEventTestFactory` — shared test data factory
- `OrgEventPublisherTest` — unit tests for publisher
- `AccountTriggerHandlerTest` — unit tests for handler

### Existing Platform Events in Org
- `sfdc_accountuser_createdSuccess__e`, `sfdc_accountuser_createdFailed__e`, `Org_Event__e`, `sfdc_order_statusChanged__e`
- ❌ Neither `sfdc_account_updated__e` nor `sfdc_user_updated__e` exist — must be CREATED

### Contact Trigger Status
No unmanaged Contact trigger exists in the org. Must be CREATED from scratch.

---

## Affected Areas

### Must CREATE (Net-New Metadata)
- `sfdc_account_updated__e` — new Platform Event + fields (`Payload__c` LTA)
- `sfdc_user_updated__e` — new Platform Event + fields
- `Event_Field_Mapping__mdt` — new Custom Metadata Type + all fields
- 36+ CMT records (22 Account + 14+ Contact mappings)
- `ContactTrigger.trigger` — new after-update trigger for Contact
- `ContactTriggerHandler.cls` — delegates to new service
- `FieldMappingService.cls` — CMT-driven dynamic comparison engine (NEW, core logic)
- `FieldMappingSelectorCache.cls` — CMT SOQL cache (static map, 1 query/tx)
- Test classes: `ContactTriggerHandlerTest`, `FieldMappingServiceTest`, `FieldMappingSelectorCacheTest`

### Must MODIFY (Extend Existing)
- `AccountTrigger` — add after-update-only path for new dynamic event
- `AccountTriggerHandler` — add `handleFieldMappingUpdate()` method for UDC-3603 event path
- `OrgEventTestFactory` — add Contact bulk factory method with all new fields

---

## Metadata Type Map (Complete)

### Platform Events
| API Name | Field | Type | Notes |
|---|---|---|---|
| `sfdc_account_updated__e` | `Payload__c` | LongTextArea(131072) | JSON payload |
| `sfdc_account_updated__e` | `PublishBehavior` | — | `PublishAfterCommit` |
| `sfdc_user_updated__e` | `Payload__c` | LongTextArea(131072) | JSON payload |
| `sfdc_user_updated__e` | `PublishBehavior` | — | `PublishAfterCommit` |

### Custom Metadata Type: `Event_Field_Mapping__mdt`
| Field API Name | Type | Purpose |
|---|---|---|
| `Salesforce_Field__c` | Text(80) | Salesforce API field name |
| `JSON_Key__c` | Text(80) | Target JSON key |
| `Object_API_Name__c` | Text(80) | 'Account' or 'Contact' |
| `Is_Active__c` | Checkbox | Toggle without deployment |
| `Is_Header_Field__c` | Checkbox | Always-include regardless of change |
| `MasterLabel` / `DeveloperName` | (standard) | Record identifier |

### CMT Records (36 Total)
**Account (22 records):** Headers + standard + custom fields
**Contact (14 records):** Headers + standard + custom fields

---

## Architecture Decision: Trigger Framework Pattern

**Chosen:** ONE trigger per object → handler class → service class (existing org pattern confirmed)
- `AccountTrigger` (thin) → `AccountTriggerHandler` (filter/route) → `FieldMappingService` (logic)
- `ContactTrigger` (thin) → `ContactTriggerHandler` (filter/route) → `FieldMappingService` (shared logic)

**Key divergence from UDC-3865:** UDC-3603 fires on ANY field change from the mapping table (not a specific status transition). The guard condition is: "at least one mapped field changed value (old != new)". Header fields bypass the guard.

---

## Governor Limit Analysis

### CMT SOQL
- Pattern: `FieldMappingSelectorCache` uses `private static Map<String, List<Event_Field_Mapping__mdt>>` cache
- First call executes SOQL, populates cache; subsequent calls return cached map
- Cost: 1 SOQL for Account + 1 SOQL for Contact (or 1 combined query filtered by `Object_API_Name__c`)
- Safe even in bulk 251-record trigger execution

### PE Publish: 150/tx Limit
- Risk level: HIGH if both Account + Contact triggers fire in same transaction
- 150 PE publish limit per transaction (across all PE types)
- Worst case: bulk update of 150 Accounts + bulk update of 150 Contacts in same tx = 300 events → exceeds limit
- Mitigation: `EventBus.publish(List<>)` counts as N publishes (one per event), not 1
- Recommendation: Document limit risk in code; in practice Account and Contact bulk updates are separate transactions via `update` DML; no Queueable needed for this use case
- Test must verify: 251-record bulk stays under 150 → actually 251 > 150. CRITICAL: bulk of 251 records = 251 events = over limit. Need to handle `SaveResult` failures gracefully.

---

## Risks

1. **PE 150/tx limit**: A bulk update of >150 qualifying Accounts or Contacts in one transaction will hit the publish limit. `EventBus.publish()` returns SaveResult with errors for exceeded records — these will be silently logged but NOT retried. This is acceptable per existing org pattern (same behavior as UDC-3865) but must be documented in code.

2. **AccountTrigger already exists**: Must carefully MODIFY (not replace) the trigger to add the new `after update` path without breaking the existing UDC-3865 logic. The existing trigger only has `after insert` + `after update` contexts — adding the CMT path requires a second handler call in the `isUpdate` block.

3. **Duplicate Id→JSON key for Account**: User story maps `Id` to both `org_sfdc_id` AND `user_sfdc_id` in the Account table. This appears to be a data error in the story. The fixed headers are `ulab_org_id` + `account_sfdc_id` per Platform Event spec. **Clarification needed** or treat as two separate CMT records emitting the same value under different keys.

4. **Header field naming discrepancy**: CMT table uses `org_sfdc_id` for Account.Id, but the PE spec says fixed header key is `account_sfdc_id`. Similarly, `org_id` vs `ulab_org_id`. The PE spec (section 1) takes precedence — headers must use `ulab_org_id` / `account_sfdc_id` and `ulab_user_id` / `contact_sfdc_id`. CMT records for header fields should use these exact JSON key values.

5. **CMT records in test context**: `Event_Field_Mapping__mdt` records are visible in test context WITHOUT `SeeAllData=true` (CMT is an exception to this rule). Static caching pattern still works in tests.

6. **`checkDuplicateContact` trigger**: An unmanaged `checkDuplicateContact` and `ContactDuplicateTrigger` exist in the org. New `ContactTrigger` must coexist peacefully — no shared state conflicts since it's after-update only.

---

## What to Retrieve vs Create From Scratch

| Item | Action | Reason |
|---|---|---|
| `AccountTrigger` | RETRIEVE + MODIFY | Already in org; must extend |
| `AccountTriggerHandler` | RETRIEVE + MODIFY | Add new handler method |
| `OrgEventPublisher` | RETRIEVE (reference only) | UDC-3865 class; UDC-3603 creates new service |
| `OrgEventPublisherConfig` | RETRIEVE (reference only) | May need minor additions |
| `OrgEventTestFactory` | RETRIEVE + MODIFY | Add new factory methods |
| `OrgEventPublisherTest` | RETRIEVE (reference only) | Pattern reference |
| `AccountTriggerHandlerTest` | RETRIEVE + MODIFY | Add new test scenarios |
| `sfdc_account_updated__e` | CREATE | Does not exist in org |
| `sfdc_user_updated__e` | CREATE | Does not exist in org |
| `Event_Field_Mapping__mdt` | CREATE | Does not exist in org |
| All CMT records | CREATE (36+) | Does not exist in org |
| `ContactTrigger` | CREATE | No unmanaged Contact trigger exists |
| `ContactTriggerHandler` | CREATE | New |
| `FieldMappingService` | CREATE | New core engine |
| `FieldMappingSelectorCache` | CREATE | New CMT cache layer |

---

## Recommendation

**Single shared `FieldMappingService`** handles both Account and Contact events. It consumes CMT records via `FieldMappingSelectorCache` and publishes to the appropriate PE (passed as parameter or resolved internally by object name). This keeps the architecture DRY and consistent with the existing org pattern.

The existing UDC-3865 `OrgEventPublisher` / `AccountTriggerHandler` logic should **NOT be removed** — it handles a different concern (Org_Event__e onboarding status) and is out of scope for UDC-3603.

---

## Ready for Proposal

Yes — all metadata types, field mappings, governor limit mitigations, and the trigger coexistence strategy are fully mapped. One clarification item remains (the duplicate `Id→user_sfdc_id` row in Account CMT table) but it can be resolved during spec with a default treatment (include as second header field under `account_sfdc_id`).
