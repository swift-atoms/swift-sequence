# Architecture

@Metadata {
    @TitleHeading("Sequence Primitives")
}

The package's place in the data-structures cohort and the design rationale for its seven library products.

## Overview

`Sequence_Primitives` is a node within **Story 2 of the data-structures cohort** (`data-structures-launch-2026`): seven packages introducing typed indexing and sequences — order, index, **sequence**, collection, input, cyclic, vector. Story 1 (cardinal, ordinal, affine) shipped 2026-05-12; Story 2 builds the protocol and pipeline surface on top.

## Product layout

Seven library products organized along the semantic axes of pipeline composition:

| Product | Target | Purpose |
|---------|--------|---------|
| `Sequence Primitives` | `Sources/Sequence Primitives/` | Umbrella — re-exports the six sub-targets below. The default import for application code. |
| `Sequence Primitives Core` | `Sources/Sequence Primitives Core/` | The protocol family — `Sequence.Protocol`, `Sequence.Iterator.Protocol`, `Sequence.Borrowing.Protocol`, `Sequence.Span`. |
| `Sequence Lazy Primitives` | `Sources/Sequence Lazy Primitives/` | Lazy pipeline wrappers — `Map`, `Filter`, `FlatMap`, `CompactMap`, `Drop.First/While`, `Prefix.First/While`. |
| `Sequence Terminal Primitives` | `Sources/Sequence Terminal Primitives/` | Terminal operations and fluent accessors — `Count`, `Contains`, `Satisfies`, `Reduce`, `First`, `ForEach`. |
| `Sequence Consuming Primitives` | `Sources/Sequence Consuming Primitives/` | Consuming-side terminators — `Drain`, `Consume.View`, `Clearable`. |
| `Sequence Difference Primitives` | `Sources/Sequence Difference Primitives/` | Myers O(ND) diff — `Difference`, `Steps`, `Changes`, `Change`, `Hunk`. |
| `Sequence Primitives Standard Library Integration` | `Sources/Sequence Primitives Standard Library Integration/` | Bridges to `Swift.Span` and `Swift.Sequence`. |
| `Sequence Primitives Test Support` | `Tests/Support/` | Fixture conformers for downstream test consumers — `Source`, `ClearableSource`, `DrainableSource`. |

## Why six sub-targets?

Sequence ships the most granular sub-target decomposition in the data-structures cohort. Cardinal and carrier each ship three sub-targets (Core / SLI / umbrella). The decomposition is intentional: each sub-target corresponds to one **semantic axis of pipeline composition**, and each axis is independently importable.

- **Core** holds the protocol family. An application that only needs `Sequence.Protocol` to write its own conforming type imports `Sequence Primitives Core` and skips all six other sub-targets.
- **Lazy** holds the closed algebra of pipeline transformers (`map`, `filter`, `flatMap`, `compactMap`, `drop`, `prefix`). Adding a new operation to this algebra touches only Lazy.
- **Terminal** holds the closed algebra of terminal operations (`count`, `contains`, `satisfies`, `reduce`, `first`, `forEach`). Same closure rule — extending the fluent surface touches only Terminal.
- **Consuming** holds the draining / clearing surface for containers whose iteration is destructive.
- **Difference** holds the Myers diff algorithm and its result types — purely additive over the protocol family.
- **SLI** holds the bridges to `Swift.Span` and `Swift.Sequence`.

Consumers willing to amortize the full compile cost import the umbrella `Sequence Primitives` and get every axis under one product. Consumers tracking compile-cost or build-graph tightness can pin to specific axes. The decomposition embodies the modularization-skill principle of "one product per cohesive responsibility" rather than the looser "one product per type cluster" pattern that cardinal and carrier follow — sequence's pipeline composition admits more axes, so the decomposition is wider.

## Dependency closure

Two direct dependencies. Each is honest — removing either breaks a load-bearing surface.

| Dependency | Why |
|------------|-----|
| `swift-index-primitives` | Provides `Index<Element>`, `Cardinal`, `Ordinal` — the typed-indexing types `nextSpan` / `Iterator` / `Drop.First` / `Prefix.First` reference. Index re-exports Cardinal and Ordinal via its umbrella; sequence consumes them through that chain. |
| `swift-property-primitives` | Provides `Property<Tag, Base>` and `Property.Inout` — the phantom-tagged fluent-accessor machinery powering `.contains { }`, `.count.where { }`, `.forEach.borrowing { }`, and the rest of the Terminal surface. |

The umbrella product re-exports both, so `import Sequence_Primitives` brings the full surface into scope with one import.

## Cohort siblings

Story 2 narrows to seven packages (down from the original nine; `link` and `cyclic-index` were cut from the launch narrative):

- order — total / partial order modeling (Wave 1, public)
- index — typed positions (Wave 1, public)
- **sequence** — typed sequence protocol (this package, Wave 2)
- collection — typed collection protocol
- input — input/iteration adapters
- cyclic — cyclic-buffer index variants
- vector — typed vector arithmetic (uses `Sequence.Protocol` as its element-iteration surface)

See `data-structures-launch-2026` for the cohort narrative.

## Foundation-free, no platform conditionals

The package is Layer 1 (primitives). No `import Foundation`, no `#if os(…)` guards, no concurrency surface (`Actor`, `async`, `await`, `CheckedContinuation` are all absent). Embedded compatibility is heuristic-supported: the iterator family inherits whatever Embedded compatibility `Span<T>` and `Index_Primitives` provide. First-party Embedded matrix runs post-flip via the centralized CI workflow.
