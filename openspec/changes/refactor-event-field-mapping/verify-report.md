# SDD Verify Report: Refactor Event Field Mapping

**Change Name:** `refactor-event-field-mapping`  
**Status:** Not Yet Started  
**Date:** 2026-07-07  
**Org:** ulab--audit (Dev)

---

## Verification Criteria

### Code Quality
- [ ] All Apex code compiles without errors
- [ ] All 28 existing Apex tests pass
- [ ] Code coverage ≥ 85%
- [ ] No new warnings or code violations

### Metadata Validation
- [ ] `JSON_Key__c` field removed; no compilation errors
- [ ] 41 new/modified CMT records deployed successfully
- [ ] No metadata deployment errors
- [ ] package.xml syntax is valid

### Functional Verification
- [ ] Event payload uses Salesforce field names as keys (not `JSON_Key__c`)
- [ ] Header fields included in payload when `Is_Active__c = true`
- [ ] Header fields excluded from payload when `Is_Active__c = false`
- [ ] Non-header fields included only if changed
- [ ] Trigger behavior unchanged; events published correctly
- [ ] No functional regressions

### Integration Tests (Sandbox)
- [ ] Account update publishes correct event payload
- [ ] Contact update publishes correct event payload
- [ ] Payload structure matches specification
- [ ] No downstream integration breaks

### Deployment Verification
- [ ] Deployment to `ulab--audit` completed successfully
- [ ] No rollback required
- [ ] All metadata changes persisted correctly

---

## Test Execution Results

### Unit Tests (Apex)

**Test Suite:** Full Run  
**Status:** ⏳ Pending

| Test Class | Tests | Pass | Fail | Coverage |
|---|---|---|---|---|
| FieldMappingServiceTest | 28 | ? | ? | ? |
| FieldMappingSelectorCacheTest | ? | ? | ? | ? |
| AccountTriggerHandlerTest | ? | ? | ? | ? |
| ContactTriggerHandlerTest | ? | ? | ? | ? |
| OrgEventPublisherTest | ? | ? | ? | ? |
| **TOTAL** | **28+** | **?** | **?** | **TBD** |

**Coverage Target:** ≥ 85%  
**Coverage Actual:** TBD

---

### Integration Tests (Sandbox)

#### Test 1: Account Event Payload Structure
- **Scenario:** Update Account.Name
- **Expected Payload:**
  ```json
  {
    "Name": "Updated Account Name",
    "uLab_Acct_Number__c": "ORG-12345",
    ...
  }
  ```
- **Actual Result:** TBD
- **Status:** ⏳ Pending

#### Test 2: Contact Event Payload Structure
- **Scenario:** Update Contact.Email
- **Expected Payload:**
  ```json
  {
    "Email": "updated@example.com",
    "Portal_User_ID__c": "P-999",
    ...
  }
  ```
- **Actual Result:** TBD
- **Status:** ⏳ Pending

#### Test 3: Header Field Inclusion (Active)
- **Scenario:** Header with `Is_Active__c = true`; Account updated
- **Expected:** Header field included in payload
- **Actual Result:** TBD
- **Status:** ⏳ Pending

#### Test 4: Header Field Exclusion (Inactive)
- **Scenario:** Header with `Is_Active__c = false`; Account updated
- **Expected:** Header field NOT included in payload
- **Actual Result:** TBD
- **Status:** ⏳ Pending

#### Test 5: Bulk Update (200+ Records)
- **Scenario:** Bulk update 200+ Accounts
- **Expected:** All events publish successfully; no governor limit violations
- **Actual Result:** TBD
- **Status:** ⏳ Pending

---

## Code Review Findings

*(To be populated during code review)*

| Finding | Severity | Status | Resolution |
|---|---|---|---|
| TBD | TBD | ⏳ Pending | TBD |

---

## Specification Compliance

### FR1: Remove JSON_Key__c Field
- [ ] Field definition removed
- [ ] No code references remain
- [ ] CMT schema compiles
- **Status:** ⏳ Pending

### FR2: Update FieldMappingService
- [ ] Method uses `Salesforce_Field__c` as key
- [ ] Header behavior unchanged
- [ ] All tests pass
- **Status:** ⏳ Pending

### FR3: Audit & Refresh CMT Records
- [ ] 19 obsolete records deleted
- [ ] 22 new records created
- [ ] Final count: 41 records
- **Status:** ⏳ Pending

### FR4: Update package.xml
- [ ] Manifest includes all 41 records
- [ ] All metadata types listed
- [ ] Deployment succeeds
- **Status:** ⏳ Pending

### FR5: Update Documentation
- [ ] JSDoc updated
- [ ] Comments reflect new key strategy
- [ ] No outdated references
- **Status:** ⏳ Pending

---

## Design Compliance

- [ ] Payload transformation correct (field names as keys)
- [ ] Bulkification maintained (200+ records supported)
- [ ] Governor limits not exceeded
- [ ] Cache-layer filtering unchanged
- [ ] Trigger behavior unchanged
- **Status:** ⏳ Pending

---

## Risk Assessment

| Risk | Impact | Mitigation | Status |
|---|---|---|---|
| CMT deployment fails | High | Fallback to anonymous Apex script | ⏳ Pending |
| Tests fail | Medium | Review error logs; verify code changes | ⏳ Pending |
| Payload breaks integrations | High | Verify in sandbox before merge | ⏳ Pending |
| Governor limits exceeded | Medium | Bulk tests verify limits | ⏳ Pending |
| Regression in trigger behavior | High | Code review validates logic | ⏳ Pending |

---

## Summary

**Overall Status:** ⏳ Not Yet Started

**Ready to Merge:** No (pending implementation and verification)

**Issues Found:** None yet

**Recommendations:**
- Proceed with implementation when ready
- Run full test suite after each task
- Verify sandbox integration tests before PR merge
- Pay special attention to payload structure validation

---

## Sign-Off

**Verification Completed:** Not yet  
**All Tests Passed:** Not yet  
**All Criteria Met:** Not yet  
**Ready to Merge:** Not yet  
**Ready for Archive:** Not yet

