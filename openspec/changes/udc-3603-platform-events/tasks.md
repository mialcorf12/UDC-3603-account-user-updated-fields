# SDD Tasks: UDC-3603 Dynamic Platform Events for Account & Contact

**Change Name:** `udc-3603-platform-events`  
**Status:** Tasks  
**Date:** 2026-07-07

---

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 950–1,200 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Delivery strategy | stacked-to-main |
| Chain strategy | stacked-to-main |

---

## Work Units

### Work Unit 1: Metadata Foundation (30 min)
- [ ] Retrieve existing Apex from org
- [ ] Create sfdc_account_updated__e Platform Event
- [ ] Create sfdc_user_updated__e Platform Event
- [ ] Create Event_Field_Mapping__mdt Custom Metadata Type
- [ ] Create CMT fields (5 total)
- [ ] Create 21 Account CMT records
- [ ] Create 17 Contact CMT records

### Work Unit 2: Core Apex — TDD (90 min)
- [ ] **RED** Create FieldMappingSelectorCacheTest.cls
- [ ] **GREEN** Create FieldMappingSelectorCache.cls
- [ ] **RED** Create FieldMappingServiceTest.cls
- [ ] **GREEN** Create FieldMappingService.cls
- [ ] Run code analyzer; remediate

### Work Unit 3: Trigger Wiring — TDD (60 min)
- [ ] **RED** Create ContactTriggerHandlerTest.cls
- [ ] **GREEN** Create ContactTriggerHandler.cls
- [ ] **GREEN** Create ContactTrigger.trigger
- [ ] **RED** Modify AccountTriggerHandlerTest.cls
- [ ] **GREEN** Modify AccountTriggerHandler.cls
- [ ] **GREEN** Modify AccountTrigger.trigger
- [ ] Run code analyzer; remediate

### Work Unit 4: Deploy & Verify (30 min)
- [ ] Deploy all new/modified metadata
- [ ] Run test suite (coverage ≥85%)
- [ ] Verify no regressions on UDC-3865 paths

---

## PR Strategy (Chained)

**PR #1: Metadata Foundation** (~400 lines)
- Platform Events, CMT schema, 38 CMT records, package.xml
- Gate: Metadata validation

**PR #2: Core Apex** (~300 lines)
- Cache + Service + Tests
- Gate: Code review + coverage ≥85%

**PR #3: Trigger Wiring** (~125 lines)
- ContactTrigger/Handler + AccountTrigger/Handler modifications
- Gate: Code review + integration tests pass

