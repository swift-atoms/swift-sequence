# Audit: swift-sequence-primitives

## Legacy — Consolidated 2026-04-08

### From: audit-zero-allocation-nextspan.md (2026-02-26)

**Scope**: Zero-allocation `nextSpan` for generating iterators — verifying research findings, experiment correctness, escaped pointer safety, Option E vs Option F rationale, Memory.Inline tier placement, and document accuracy.

**Auditor**: Claude | **Status**: RECOMMENDATION

| Severity | Count |
|----------|-------|
| VERIFIED | 3 |
| CHALLENGED | 1 |
| FLAGGED | 1 |
| (Item 1 is experiment verification) | 1 |

**Summary of 6 items**:

| # | Item | Verdict | Status |
|---|------|---------|--------|
| 1 | Build and run experiments | VERIFIED | RESOLVED — all 3 experiments compile and run, output matches claims |
| 2 | V2 REFUTED finding (withUnsafePointer borrowing) | VERIFIED (with precision note) | RESOLVED — borrowing overload does not guarantee address identity for Copyable types; conclusion correct, wording needs precision |
| 3 | Escaped pointer safety | VERIFIED (with caveat) | RESOLVED — pattern matches existing Storage.Inline infrastructure; relies on struct layout stability (reasonable but undocumented guarantee) |
| 4 | Option E necessity over Option F | CHALLENGED | OPEN — Option F "Copyable only" claim is wrong; Optional<Element> supports ~Copyable in Swift 6.2. Option E still preferred for zero overhead + no layout assumptions, but rationale in research doc needs correction |
| 5 | Memory.Inline tier placement | VERIFIED | RESOLVED — Tier 13 (memory) correct, downward dependency to Tier 14 (storage) confirmed |
| 6 | Research document gaps | FLAGGED (3 corrections needed) | OPEN — three text corrections needed in the research document plus one stale comment in experiment 3 |

**Key patterns**:
- Option E (@_rawLayout / Memory.Inline) remains the correct primary approach
- The documented rationale incorrectly claims Option F is "Copyable only" — this must be corrected
- Escaped pointer pattern validated against Storage.Inline precedent
- `withUnsafePointer(to:)` borrowing overload does not guarantee address identity for Copyable stored properties

**Cross-references**: `zero-allocation-nextspan-for-generating-iterators.md` (the research document being audited)

---

### From: swift-institute/Research/audits/implementation-naming-2026-03-20/swift-sequence-primitives.md (2026-03-20)

**Implementation + naming audit**

HIGH=1, MEDIUM=4, LOW=4, INFO=3
Finding IDs: IMPL-002, IMPL-010, IMPL-033, PATTERN-017, SEQ-001, SEQ-002, SEQ-003, SEQ-004, SEQ-005, SEQ-006, SEQ-007

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 3 |
| INFO | 2 |
