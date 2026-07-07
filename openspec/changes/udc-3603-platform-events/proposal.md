# SDD Proposal: UDC-3603 Dynamic Platform Events for Account & Contact

**Change Name:** `udc-3603-platform-events`  
**Status:** Proposal  
**Date:** 2026-07-07

---

## Intent

Implement a decoupled, dynamically configurable Custom Metadata Type (CMT) architecture to capture changes on Account and Contact records. The goal is to notify external systems only about modified fields without hardcoding field tracking logic, allowing administrators to configure tracked fields easily without requiring code deployments.

---

## Scope

### In Scope
- Create Custom Metadata Type `Event_Field_Mapping__mdt` and 36+ initial CMT records for mapped fields.
- Create two Platform Events: `sfdc_account_updated__e` and `sfdc_user_updated__e`.
- Create a shared logic engine `FieldMappingService` to evaluate changed fields dynamically and build JSON payloads.
- Create `FieldMappingSelectorCache` for bulk-safe caching of CMT records.
- Create `ContactTrigger` (after update) and `ContactTriggerHandler`.
- Modify `AccountTrigger` and `AccountTriggerHandler` to include the new logic without disrupting the existing UDC-3865 flow.
- Add robust Apex tests providing full code coverage and verifying null handling, bulk limits, and always-included headers.

### Out of Scope
- Migrating or altering the existing UDC-3865 `Org_Event__e` flow.
- Retrying Platform Event publishes if the 150/tx limit is exceeded (will be logged per existing pattern).
- Handling operations other than `after update`.

---

## Capabilities

### New Capabilities
- `dynamic-field-mapping`: A service mapping engine leveraging CMT caching to evaluate SObject changes, append fixed headers, explicitly capture null values, and publish dynamic JSON payloads via Platform Events.
- `contact-update-events`: Trigger and handler logic capturing Contact updates and routing them through the dynamic field mapping service.

### Modified Capabilities
- `account-update-events`: Extending existing Account after-update flow to invoke the new dynamic field mapping service alongside existing legacy UDC-3865 logic.

---

## Approach

We will build a single shared `FieldMappingService` class to evaluate field changes for both Account and Contact events dynamically via `SObject.get()`. CMT mappings will be cached via `FieldMappingSelectorCache` (1 SOQL per transaction). The service will identify old vs new field value differences, inject fixed header keys unconditionally, serialize to JSON, and publish the events. The new `ContactTrigger` and modified `AccountTrigger` will delegate to this service inside their `after update` contexts.

---

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `objects/sfdc_account_updated__e` | New | Platform event for Account updates |
| `objects/sfdc_user_updated__e` | New | Platform event for Contact updates |
| `objects/Event_Field_Mapping__mdt` | New | Custom Metadata Type definition |
| `customMetadata/*` | New | 36 CMT records for Accounts & Contacts |
| `triggers/ContactTrigger` | New | Captures Contact updates |
| `classes/ContactTriggerHandler` | New | Delegates Contact updates |
| `classes/FieldMappingService` | New | Core dynamic comparison & event publishing engine |
| `classes/FieldMappingSelectorCache` | New | Caches CMT records to avoid SOQL in loops |
| `triggers/AccountTrigger` | Modified | Triggers new dynamic process |
| `classes/AccountTriggerHandler` | Modified | Routes to FieldMappingService alongside existing processes |
| `classes/OrgEventTestFactory` | Modified | Add contact + account testing utilities |

---

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| PE 150 limit exceeded on bulk updates | Medium | 150/tx limit will be reached if bulk >150 records is processed. SaveResult failures will be logged (no retry), matching existing org behavior pattern. |
| CMT duplicate Account mapping | Low | The table lists `Id` -> `user_sfdc_id` for Account. We will interpret this as a fixed header rule if needed, clarifying the exact JSON keys during implementation specs (using the PE spec headers explicitly). |
| AccountTrigger modification conflict | Low | Modification will safely append to `after update` block without touching existing UDC-3865 logic. |

---

## Rollback Plan

Delete the `ContactTrigger`, revert `AccountTrigger` and `AccountTriggerHandler` from version control history. Deactivate or delete the `Event_Field_Mapping__mdt` records or the Apex classes.

---

## Dependencies

- Existing UDC-3865 logic remaining untouched.
- `ulab--audit` sandbox (Dev alias).

---

## Success Criteria

- [ ] Updating a mapped field on Account publishes `sfdc_account_updated__e` with exact JSON keys and headers.
- [ ] Updating a mapped field on Contact publishes `sfdc_user_updated__e` with exact JSON keys and headers.
- [ ] Updating an unmapped field publishes no event.
- [ ] Setting a mapped field to null produces a JSON `null` in the payload.
- [ ] 1 SOQL query used per transaction for mapping logic (verified via tests).
- [ ] Bulk update works safely up to 150 records, and logs errors beyond 150 without crashing.

