# Sequence Primitives Scope

`swift-sequence-primitives` provides the **sequence-iteration substrate**: the
`Sequence` namespace, the `Sequence.Protocol` family (with first-class
`~Copyable` support stdlib's `Sequence` lacks), the lazy-wrapper algebra, the
terminal-operation algebra, consuming-side draining, the Myers diff, and the
stdlib-bridge surface. It is the vocabulary every higher container, collection,
and pipeline type builds its iteration on.

## Per-[MOD-031] shape

The package follows `[MOD-031]` per-sub-namespace decomposition: `Sequence
Primitive` is the layer-invariant zero-dep namespace target per `[MOD-017]`, and
each conceptual axis (protocol family, lazy wrappers, terminals, consuming,
algorithms, stdlib integration) is its own target declaring only the
dependencies it genuinely consumes. There is no implementation-bearing
`Sequence Primitives Core` target — the legacy `[MOD-001]` Core convention is
deprecated, and the L1 core-dissolution sweep (2026-06-23) relocated the root
namespace into `Sequence Primitive`.

## Core targets

- **Sequence Primitive** — the `public enum Sequence {}` namespace target. Zero
  external deps per `[MOD-017]`. Owns the `Sequence` namespace root.
- **Sequence Iterator Primitives** — `Sequence.Iterator` types and the typed-index
  iteration surface.
- **Sequence Protocol Primitives** — the `Sequence.Protocol` family
  (`Sequence.Protocol`, `Sequence.Iterator.Protocol`, `Sequence.Drain.Protocol`),
  with `~Copyable` container and element support.
- **Sequence Borrowing Primitives** — `Sequence.Borrowing.Protocol` and the
  borrowing-iteration surface.
- **Sequence Span Primitives** — the `Sequence.Span` integration types.
- **Sequence Map / Filter / Drop / Prefix Primitives** — the lazy-wrapper algebra
  (`Sequence.Map<Base>` with `.Eager`/`.Compact`/`.Flat`, `Sequence.Filter`,
  `Sequence.Drop.First/While`, `Sequence.Prefix.First/While`).
- **Sequence ForEach / Satisfies / Contains / First / Reduce / Hint Primitives** —
  the terminal-operation algebra via the fluent `.<op>` accessor surface
  (`Property.Inout`-backed); `Sequence.Hint` namespaces cheap size hints.
- **Sequence Drain Primitives** — consuming-side draining via
  `Sequence.Drain.Protocol` and the consuming `consume(_:)` terminal.
- **Sequence Difference Primitives** — the Myers O(ND) diff (`Sequence.Difference`,
  `Steps`, `Changes`, `Change`, `Hunk`).
- **Sequence Primitives Standard Library Integration** — `Swift.Span.Iterator`,
  its `Batch`, and the `Sequence.Protocol` ⇄ `Swift.Sequence` adapter.
- **Sequence Primitives** — umbrella; re-exports every sub-namespace product so
  consumers needing the union write `import Sequence_Primitives`.
- **Sequence Primitives Test Support** — published test-fixtures product
  (`Source`, `Drainable.Source` conformers).

## Out of scope

- Eager/random-access collection semantics (indexing, slicing as a stored view)
  — `swift-collection-primitives` and the container-specific primitives packages.
- Typed index / cardinal / ordinal machinery — `swift-index-primitives`
  (consumed, not re-implemented).
- The phantom-tagged fluent-accessor machinery (`Property` / `Property.Inout`)
  — `swift-property-primitives` (consumed, not re-implemented).
- The iterator protocol substrate and chunk primitives — `swift-iterator-primitives`
  (consumed, not re-implemented).
- Concurrency-aware iteration (`AsyncSequence`-style surfaces, `async`/`await`)
  — out of the L1 Foundation-free, no-concurrency boundary; a future sibling
  package when needed.

## Evaluation rule

Sub-target additions are evaluated against this scope. If a proposed addition is
OUT of scope, it extracts to a sibling package, not into this one.

- A proposed addition that is a **new iteration-axis surface** (a new lazy
  wrapper, a new terminal operation, a new consuming form) lands in its own
  per-sub-namespace target per `[MOD-031]`, declaring its own dependencies.
- A proposed addition that belongs to a **different L1 axis** (collection
  storage, indexing, properties, the iterator substrate) is consumed from its
  owning sibling package, never re-implemented here.
