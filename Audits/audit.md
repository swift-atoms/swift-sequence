# Audit: swift-sequence-primitives

## Code Surface — 2026-05-05

### Scope

- **Target**: `Sequence.\`Protocol\`` and its sibling protocols in `Sequence Primitives Core`
- **Skill**: code-surface — opaque-return-type ergonomics for downstream consumers
- **Files**: 3 source files
  - `Sources/Sequence Primitives Core/Sequence.Protocol.swift`
  - `Sources/Sequence Primitives Core/Sequence.Iterator.Protocol.swift`
  - `Sources/Sequence Primitives Core/Sequence.Borrowing.Protocol.swift`
- **Trigger**: surfaced 2026-05-05 during the swift-graph-primitives `nodes`-accessor workaround discussion (Vector-based fix landed; opaque ecosystem return shape `some Sequence_Primitives.Sequence.\`Protocol\`<Element>` was the user's preferred shape but is currently inexpressible — see investigation pointer below).

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | LOW | (no specific requirement ID — ergonomic enhancement) | `Sequence.Protocol.swift:92` | `Sequence.\`Protocol\`` declares `associatedtype Element: ~Copyable` as a regular (non-primary) associated type. Consumers who want opaque-return-type accessors of the form `some Sequence_Primitives.Sequence.\`Protocol\`<MyElement>` are blocked: the compiler rejects with `error: protocol 'Sequence.\`Protocol\`' does not have primary associated types that can be constrained`. Promoting to `public protocol \`Protocol\`<Element>: ~Copyable, ~Escapable { ... }` is additive — every existing `extension where Element == X` keeps working — and unlocks the constrained-opaque-return shape across every consumer. | DEFERRED — small ecosystem-positive change deferred for a separate authorized cycle. Investigation pointer: `/Users/coen/Developer/HANDOFF-graph-primitives-sigabrt-earlyperf-inliner.md` Findings section "Workaround attempts on the secondary bug" item 4. The current graph-primitives fix sidesteps the need by reusing concrete `Vector<Bound>` (which conforms to both ecosystem `Sequence.\`Protocol\`` and `Swift.Sequence`); promotion remains valuable for future consumers who want the opaque shape without a concrete name. |
| 2 | LOW | (no specific requirement ID — consistency follow-up to #1) | `Sequence.Iterator.Protocol.swift:109` | Same shape as #1: `Sequence.Iterator.\`Protocol\`` declares `associatedtype Element: ~Copyable` non-primary. Mirror promotion (`public protocol \`Protocol\`<Element>: ~Copyable, ~Escapable { ... }`) keeps the protocol family consistent. Without it, downstream conformers and constrained-opaque-return code on iterators face the same blocker as #1. | DEFERRED — same investigation pointer as #1; resolve as a unit to keep `Sequence.\`Protocol\``-family ergonomics symmetric. |
| 3 | LOW | (no specific requirement ID — consistency follow-up to #1) | `Sequence.Borrowing.Protocol.swift:47` | Same shape as #1: `Sequence.Borrowing.\`Protocol\`` declares `associatedtype Element` non-primary. Mirror promotion completes the protocol-family pattern. | DEFERRED — same investigation pointer as #1. |

### Summary

3 findings, all LOW severity, all DEFERRED. None are correctness or convention violations against existing code-surface requirement IDs; they are recorded here per [AUDIT-017] (parking destination for deferred investigations) because the improvement was identified and the design is well-formed but landing it is deferred for a separate authorized cycle.

The pattern is uniform: three sibling protocols (`Sequence.\`Protocol\``, `Sequence.Iterator.\`Protocol\``, `Sequence.Borrowing.\`Protocol\``) all declare `Element` as a regular associated type. Promoting `Element` to a primary associated type on each (additive, ABI-compatible — every existing `extension where Element == X` continues to compile) unlocks the constrained-opaque-return-type shape `some Sequence_Primitives.Sequence.\`Protocol\`<MyElement>` ecosystem-wide. The blocker surfaced during a downstream consumer's API design (graph-primitives `nodes` accessor); the immediate workaround there reused concrete `Vector_Primitives.Vector<Bound>` (which conforms to both protocols) so no upstream change was required to unblock that consumer. The promotion remains a small, valuable ergonomic improvement for future consumers who want the opaque-with-element-constraint shape.

When this lands, all three protocols should be promoted in the same change to keep the family consistent. Verification: `swift build -c release` clean across consumers; spot-check that `extension Sequence.\`Protocol\` where Element == X` style declarations and `extension Sequence.\`Protocol\`` (no constraint) declarations both still type-check (additive primary-associated-type promotion does not require existing `where Element == X` syntax to change).

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
