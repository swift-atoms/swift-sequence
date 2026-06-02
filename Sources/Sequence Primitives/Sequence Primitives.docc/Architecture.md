# Architecture

@Metadata {
    @TitleHeading("Sequence Primitives")
}

The package's product layout — 22 library products organized per sub-namespace, plus an umbrella that re-exports them all.

## Overview

`Sequence_Primitives` ships the protocol family, the lazy wrapper algebra, the terminal-operation algebra, draining/clearing for consuming-side containers, a Myers diff, and the stdlib-bridge surface. The decomposition follows `[MOD-031]` — one library product per sub-namespace — so consumers tracking compile cost can pin to specific surfaces without paying for the rest.

## Product layout

22 library products grouped by conceptual axis. Each row of the table corresponds to one importable target; each axis groups related targets.

| Axis | Library products | Purpose |
|---|---|---|
| Protocol family | `Sequence Namespace`, `Sequence Iterator`, `Sequence Protocol`, `Sequence Borrowing`, `Sequence Span` | The `Sequence.Protocol` family, `Sequence.Iterator.Protocol`, `Sequence.Borrowing.Protocol`, and the `Sequence.Span` integration types. |
| Lazy pipeline | `Sequence Map`, `Sequence Filter`, `Sequence Drop`, `Sequence Prefix` | Lazy wrappers — `Sequence.Map<Base>` (with nested `.Eager`/`.Compact`/`.Flat`), `Sequence.Filter`, `Sequence.Drop.First/While`, `Sequence.Prefix.First/While`. |
| Terminal operations | `Sequence ForEach`, `Sequence Satisfies`, `Sequence Contains`, `Sequence First`, `Sequence Reduce`, `Sequence Hint` | Terminal ops via the fluent `.<op>` accessor surface (Property.Inout-backed). `Sequence.Hint` namespaces cheap-but-imprecise size hints (`hint.count`). |
| Consuming-side | `Sequence Drain`, `Sequence Clearable` | Draining, the consuming `Sequenceable.consume(_:)` terminal (deinit-based cleanup on early exit), and the `Sequence.Clearable` refinement. |
| Diff algorithm | `Sequence Difference` | Myers O(ND) diff — `Sequence.Difference`, `Steps`, `Changes`, `Change`, `Hunk`. |
| Stdlib bridges | `Sequence Standard Library Integration` | `Swift.Span.Iterator`, `Swift.Span.Iterator.Batch`, and the `Sequence.Protocol` ⇄ `Swift.Sequence` adapter. |
| Umbrella | `Sequence Primitives` | Re-exports every sub-namespace product. The default import for application code. |
| Test infrastructure | `Sequence Primitives Test Support` | Fixture conformers — `Source`, `Clearable.Source`, `Drainable.Source` — for downstream test code. |

## Why per-sub-namespace decomposition?

Per `[MOD-031]`, each sub-namespace gets its own target. This produces three properties:

- **Selective import.** An application that only needs `Sequence.Protocol` to write its own conforming type imports `Sequence Protocol` and skips compilation of every other surface (lazy ops, terminal ops, diff, etc.). Compile cost scales with what's used, not what's available.
- **Single-axis change isolation.** Adding a new lazy operation touches one target (e.g., extending `Sequence.Filter`). Adding a new terminal operation touches one target (e.g., extending `Sequence.Reduce`). Cross-axis changes are explicit and visible.
- **Predictable dependency surface.** Every target's `dependencies:` declaration lists only what it genuinely consumes. No "everything depends on everything" via a fat Core target.

Consumers willing to amortize the full compile cost import the umbrella `Sequence Primitives` and get every axis under one product.

## Dependency closure

Two direct dependencies. Each is honest — removing either breaks a load-bearing surface.

| Dependency | Why |
|------------|-----|
| `swift-index-primitives` | Provides `Index<Element>`, `Cardinal`, `Ordinal` — the typed-indexing types `nextSpan` / `Iterator` / `Drop.First` / `Prefix.First` reference. Index re-exports Cardinal and Ordinal via its umbrella; sequence consumes them through that chain. |
| `swift-property-primitives` | Provides `Property<Tag, Base>` and `Property.Inout` — the phantom-tagged fluent-accessor machinery powering `.contains { }`, `.satisfies.all { }`, `.forEach.borrowing { }`, and the rest of the Terminal surface. |

The umbrella product re-exports both, so `import Sequence_Primitives` brings the full surface into scope with one import.

## Foundation-free, no platform conditionals

No `import Foundation`, no `#if os(…)` guards, no concurrency surface (`Actor`, `async`, `await`, `CheckedContinuation` are all absent). Swift Embedded is supported — the Wasm SDK build and Swift 6.4-dev nightly Embedded matrix both pass in CI.
