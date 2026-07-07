# SDD Proposal: Refactor Event Field Mapping to Use Salesforce Field Names as Payload Keys

**Change Name:** `refactor-event-field-mapping`  
**Status:** Proposal  
**Date:** 2026-07-07  
**Org:** ulab--audit (Dev)  
**API Version:** 66.0

---

## Problem Statement

The `Event_Field_Mapping__mdt` custom metadata currently uses a `JSON_Key__c` field to define arbitrary payload keys in the Platform Event publish flow. This creates unnecessary indirection and maintenance burden:

- A field named `uLab_Acct_Number__c` in Salesforce has a `JSON_Key__c` value of `ulab_org_id` in the event payload
- This mapping is stored in 38+ metadata records, each with its own `JSON_Key__c` value
- Developers must maintain two names for every field: the Salesforce name AND the arbitrary JSON key
- The arbitrary keys provide no additional value — they're just noise

**Current Payload Example:**
```json
{
  "org_name": "Acme Corp",
  "ulab_org_id": "ORG-12345",
  "is_parent": true
}
```

**Target Payload Example:**
```json
{
  "Name": "Acme Corp",
  "uLab_Acct_Number__c": "ORG-12345",
  "Is_Parent__c": true
}
```

---

## Business Outcomes

1. **Reduced Maintenance Burden:** Remove 41 `JSON_Key__c` values from metadata; use Salesforce field names directly
2. **Improved Clarity:** Payload keys match Salesforce field API names — no translation layer needed
3. **Easier Integration Testing:** Downstream systems map events directly to Salesforce field names
4. **No Functional Change:** Event publish logic and header behavior remain unchanged

---

## Scope

### In Scope
- Remove `JSON_Key__c` field from `Event_Field_Mapping__mdt` object schema
- Update `FieldMappingService.buildPayload()` to use `Salesforce_Field__c` as the map key instead of `JSON_Key__c`
- Delete 5 obsolete Contact CMT records (TOU agreement fields + old headers)
- Delete 14 obsolete Account CMT records (Billing/Shipping address, old headers)
- Create 22 new CMT records (14 Account + 8 Contact) with correct field mappings and no `JSON_Key__c`
- Update `package.xml` to reflect all 41 final CMT records
- Update JSDoc and inline comments to document the new key strategy

### Out of Scope
- Changes to trigger behavior or event publication logic
- Changes to header field filtering (already happens at cache layer)
- Changes to any other metadata types or Apex logic outside FieldMappingService

---

## High-Level Approach

1. **Remove Field:** Delete `JSON_Key__c` field definition from `Event_Field_Mapping__mdt`
2. **Update Service Logic:** Modify `FieldMappingService.buildPayload()` to use `Salesforce_Field__c` as the key
3. **Audit & Refresh CMT Records:** Remove old records, create 41 new ones with correct field mappings
4. **Deploy & Test:** Run full test suite (85%+ coverage required); verify event payload structure in sandbox
5. **PR Strategy:** 3 chained PRs (metadata + code → tests → final cleanup)

---

## Success Criteria

- ✅ `JSON_Key__c` field removed; CMT schema compiles
- ✅ `FieldMappingService.buildPayload()` uses `Salesforce_Field__c` as key; all existing tests pass
- ✅ 41 CMT records deployed; Event_Field_Mapping__mdt cache loads correctly
- ✅ Test coverage ≥ 85% on all modified classes
- ✅ Event publish flow produces correct payload structure in sandbox
- ✅ No functional regressions; header behavior unchanged

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| CMT deployment fails | Low | High | Use CLI deploy + fallback anonymous Apex script |
| Payload structure breaks downstream integrations | Medium | High | Verify payload in sandbox before PR merge |
| Test coverage drops | Low | Medium | Run full test suite; enforce 85% gate |
| Header filtering behavior changes | Low | High | Cache layer filtering verified in code review |

---

## Dependencies

- Salesforce CLI v2 (sf)
- API v66.0 sandbox (ulab--audit)
- Existing test suite (FieldMappingServiceTest.cls, FieldMappingSelectorCacheTest.cls, etc.)
- No external integrations blocked during deployment

---

## Stakeholders

- Backend: Owns FieldMappingService, event publish logic
- QA: Tests payload structure in sandbox
- Integration Team: Validates downstream event consumption (if applicable)

---

## Decision Gates

- **Gate 1 (Proposal):** Confirm problem statement and approach. Approve proceeding to spec.
- **Gate 2 (Spec):** Validate requirements; confirm 41 CMT records and field mappings. Approve proceeding to design.
- **Gate 3 (Design):** Review architecture; confirm bulkification, test strategy, deployment plan. Approve proceeding to tasks.
- **Gate 4 (Tasks):** Review task breakdown; estimate effort. Approve proceeding to apply.
- **Gate 5 (Apply):** All tests pass; coverage ≥ 85%. Approve PR merge.
