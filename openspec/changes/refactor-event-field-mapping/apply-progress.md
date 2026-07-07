# SDD Apply Progress: Refactor Event Field Mapping

**Change Name:** `refactor-event-field-mapping`  
**Status:** Not Yet Started  
**Date:** 2026-07-07  
**Org Target:** ulab--audit (Dev)  
**API Version:** 66.0

---

## Work Unit Execution Log

### Work Unit 1: Metadata Schema Changes
- **Status:** ⏳ Pending
- **Effort:** 30 minutes
- **Completed Tasks:** 0/2

#### Task 1.1: Remove JSON_Key__c Field Definition
- **Status:** ⏳ Pending
- **Notes:** None

#### Task 1.2: Update Event_Field_Mapping__mdt Object Description
- **Status:** ⏳ Pending
- **Notes:** None

---

### Work Unit 2: Apex Code Changes
- **Status:** ⏳ Pending
- **Effort:** 45 minutes
- **Completed Tasks:** 0/3

#### Task 2.1: Refactor FieldMappingService.buildPayload()
- **Status:** ⏳ Pending
- **Notes:** None

#### Task 2.2: Update FieldMappingService JSDoc & Comments
- **Status:** ⏳ Pending
- **Notes:** None

#### Task 2.3: Verify Apex Tests Pass
- **Status:** ⏳ Pending
- **Coverage:** TBD
- **Test Results:** TBD

---

### Work Unit 3: Custom Metadata Records — Deletions
- **Status:** ⏳ Pending
- **Effort:** 20 minutes
- **Completed Tasks:** 0/2

#### Task 3.1: Delete Obsolete Contact CMT Records
- **Status:** ⏳ Pending
- **Records Deleted:** 0/5
- **Notes:** None

#### Task 3.2: Delete Obsolete Account CMT Records
- **Status:** ⏳ Pending
- **Records Deleted:** 0/14
- **Notes:** None

---

### Work Unit 4: Custom Metadata Records — Creations (Account)
- **Status:** ⏳ Pending
- **Effort:** 45 minutes
- **Completed Tasks:** 0/2

#### Task 4.1: Create 21 New Account CMT Records
- **Status:** ⏳ Pending
- **Records Created:** 0/21
- **Notes:** None

#### Task 4.2: Create 20 New Contact CMT Records
- **Status:** ⏳ Pending
- **Records Created:** 0/20
- **Notes:** None

---

### Work Unit 5: Deployment Manifest
- **Status:** ⏳ Pending
- **Effort:** 15 minutes
- **Completed Tasks:** 0/2

#### Task 5.1: Update package.xml with All Metadata
- **Status:** ⏳ Pending
- **Members Added:** 0/41 CMT + 12 Apex + 2 Triggers + 3 Objects + 6 Fields
- **Notes:** None

#### Task 5.2: Verify package.xml Syntax
- **Status:** ⏳ Pending
- **Validation Result:** TBD

---

### Work Unit 6: Deployment & Verification
- **Status:** ⏳ Pending
- **Effort:** 30 minutes
- **Completed Tasks:** 0/3

#### Task 6.1: Deploy Metadata to Sandbox
- **Status:** ⏳ Pending
- **Deployment Result:** TBD
- **Errors:** None yet

#### Task 6.2: Run Apex Test Suite
- **Status:** ⏳ Pending
- **Tests Passed:** 0/28
- **Coverage:** TBD (Target: ≥ 85%)

#### Task 6.3: Manual Sandbox Integration Test
- **Status:** ⏳ Pending
- **Test Result:** TBD
- **Payload Verified:** No

---

## Commit Log

*(Will be updated as tasks complete)*

```
--- No commits yet ---
```

---

## Issues & Blockers

*(Will be updated as issues arise)*

- None yet

---

## Next Steps

1. Start Work Unit 1: Remove `JSON_Key__c` field and update object description
2. Proceed through Work Units 2-6 in sequence
3. Update this file after each task completion
4. On completion of all tasks, transition to `sdd-verify` phase

---

## Sign-Off

**Implementation Started:** Not yet  
**All Tasks Completed:** Not yet  
**Coverage ≥ 85%:** Not yet  
**Sandbox Deployment Verified:** Not yet  
**Ready for Verify Phase:** Not yet

