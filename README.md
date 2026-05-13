# Sequence Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Iterator and sequence primitives for Swift — `Sequence.Protocol` with `~Copyable` element support, lazy map/filter/flatMap/prefix/drop pipelines, terminal operations via fluent `.<op>` accessors, and a Myers-difference implementation.

Stdlib's `Swift.Sequence` requires `Element: Copyable` (per SE-0427). `Sequence.Protocol` in this package lifts that constraint so move-only and lifetime-bound element types — `Span<T>`, file descriptors, unique resource handles — can be iterated without being copied. The protocol family pairs with a `nextSpan(maximumCount:)` primitive that returns borrowed sub-spans into the source, enabling batch iteration without an intermediate heap allocation per element.

This package is part of **Story 2 of the data-structures cohort** (`data-structures-launch-2026`): seven packages introducing typed indexing and sequences — order, index, **sequence**, collection, input, cyclic, vector. Story 1 (cardinal, ordinal, affine) shipped 2026-05-12. Within Story 2, sequence depends on the already-public `index` (Wave 1) and Tier 0 `property`.

---

## Quick Start

```swift
import Sequence_Primitives

// `source` here is any `Sequence.Protocol` conformer — your own type, or
// a concrete container from a downstream package (Vector_Primitives, etc.).
let source: some Sequence.`Protocol`<Int> = makeSource([1, 2, 3, 4, 5, 6])

// Lazy pipeline — each stage produces a new Sequence.Protocol conformer
// with no element copies until a terminal op consumes the stream.
let doubledEvens = source
    .map { $0 * 2 }
    .filter { $0 % 4 == 0 }

// Terminal ops via the fluent `.<op>` Property.Inout accessors
let total       = doubledEvens.count.all                     // Cardinal(3)
let firstMatch  = doubledEvens.first { $0 > 8 }              // Optional(12)
let anyOver10   = doubledEvens.satisfies.any { $0 > 10 }     // true

// forEach takes the closure directly; .forEach.borrowing { } and
// .forEach.consuming { } are the explicit-ownership variants.
doubledEvens.forEach { element in
    print(element)  // 4, 8, 12
}
```

For `~Copyable` element types, the same pipeline works without copies — `Sequence.Map<Base, Output>` carries the `~Copyable` constraint forward through the iterator chain, and the `nextSpan` primitive yields borrowed spans rather than owned elements.

---

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Seven library products organized along the semantic axes of pipeline composition: protocol family, consuming terminators, lazy wrappers, terminal operators, diff algorithm, stdlib bridges, and an umbrella that re-exports the lot.

| Product | When to import | What's in it |
|---------|---------------|--------------|
| `Sequence Primitives` (umbrella) | Default for application code | Re-exports the six sub-targets below as one import. |
| `Sequence Primitives Core` | Just the protocol family + Span integration | `Sequence.Protocol`, `Sequence.Iterator.Protocol`, `Sequence.Borrowing.Protocol`, `Sequence.Span`. |
| `Sequence Lazy Primitives` | Building pipelines without terminal ops | `Sequence.Map`, `Filter`, `FlatMap`, `CompactMap`, `Drop.First/While`, `Prefix.First/While` and their iterators. |
| `Sequence Terminal Primitives` | Adding terminal operations to existing pipelines | `Sequence.Count`, `Contains`, `Satisfies`, `Reduce`, `First`, `ForEach` and the fluent `.<op>` accessors. |
| `Sequence Consuming Primitives` | Containers that need draining or clearing | `Sequence.Drain`, `Sequence.Consume.View`, `Sequence.Clearable`. |
| `Sequence Difference Primitives` | Computing edit scripts between two sequences | `Sequence.Difference` (Myers O(ND) diff), `Steps`, `Changes`, `Change`, `Hunk`. |
| `Sequence Primitives Standard Library Integration` | Bridging to `Swift.Span` / `Swift.Sequence` | `Swift.Span.Iterator`, `Swift.Span.Iterator.Batch`, and the `Sequence.Protocol` ⇄ `Swift.Sequence` adapter. |

Foundation-free across every sub-target. The umbrella product is the default; consumers who care about compile cost can pin to specific axes (importing only `Sequence Lazy Primitives` skips Terminal, Difference, Consuming, and SLI compilation).

### Why six sub-targets?

Sequence ships the most granular sub-target decomposition in the data-structures cohort — cardinal and carrier ship three sub-targets each (Core / SLI / umbrella). The decomposition reflects the **semantic axes of pipeline composition**: the protocol family lives in Core, the lazy wrappers form a closed algebra (map/filter/flatMap/compactMap/drop/prefix), terminal ops form another (count/contains/satisfies/reduce/first/forEach), draining/clearing is consuming-side, diff is its own algorithmic surface, and the stdlib bridges live in SLI. Each axis is independently importable; an application that only needs the protocol family for its own conforming type imports `Sequence Primitives Core` and skips compilation of the lazy / terminal / diff / consuming surface entirely. Consumers willing to amortize the full compile cost import the umbrella `Sequence Primitives` and get every axis under one product.

---

## `~Copyable` element support

`Sequence.Protocol` declares `associatedtype Element: ~Copyable`. The constraint flows through the entire iterator family — every `Iterator` type is `~Copyable & ~Escapable`, every lazy wrapper preserves the `~Copyable` of the base element via `borrowing` closure parameters, and the `nextSpan(maximumCount:)` primitive returns a `Span<Element>` borrowed from the iterator state rather than an owned collection of elements.

This is the delta against stdlib `Swift.Sequence`: SE-0427 constrained `Swift.Sequence.Element` to `Copyable`, which closes off iteration over move-only types. The protocol family in this package is parameterized so consumers can build sequences over file descriptors, unique resource handles, or any other `~Copyable` type without losing access to the lazy/terminal/diff surface.

For types that need to be iterated without being consumed, `Sequence.Borrowing.Protocol` is the variant: it preserves the original sequence as a borrowed reference, enabling repeated iteration without forfeit of ownership.

---

## `nextSpan(maximumCount:)`

Every iterator in this package implements `nextSpan(maximumCount:) -> Span<Element>` as its primitive method; `next() -> Element?` is a convenience built on top.

The contract: each call returns a borrowed span into the iterator's internal storage (or, for lazy wrappers, the wrapped iterator's storage). The caller may consume the span in place; the next call invalidates the previous return value. This is the moral equivalent of stdlib's `withContiguousStorageIfAvailable`, lifted to the iterator level and made unconditional rather than opportunistic.

The performance posture is documented in `Research/zero-allocation-nextspan-for-generating-iterators.md` and `Research/zero-allocation-nextspan-for-vector-iterators.md`. Generating iterators that produce one element at a time (`Map.Iterator`, `Filter.Iterator`, `CompactMap.Iterator`, `FlatMap.Iterator`) use an `Optional<Element>` inline-stored buffer and return a 1-element span pointing at the buffer — zero heap allocation, zero copies.

---

## Safety surface

The package carries 45 `unsafe`-marked sites concentrated in the SLI bridge to `Swift.Span` and in the inline-buffer pattern used by generating iterators (`@_rawLayout` / `withUnsafeMutablePointer` / `assumingMemoryBound`). Every `@safe`-attributed declaration carries an adjacent `## Safety Invariant` section in its doc comment per [MEM-SAFE-025c] disclosing the invariant relied on; every other `unsafe` site carries an inline `// WHY:` comment naming the invariant. The discipline is enforced by the swift-linter `Lint.Rule.Memory.SafeAttributeUndocumented` rule.

The single `WORKAROUND` site at `Sources/Sequence Difference Primitives/Sequence.Difference+core.swift` is annotated with the four-part `// WORKAROUND:` / `// WHY:` / `// WHEN TO REMOVE:` / `// TRACKING:` template per [DOC-045].

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Linux | Full support (post-flip CI matrix) |
| Windows | Full support (post-flip CI matrix) |
| Swift Embedded | Heuristic-supported (no Foundation, no concurrency surface) — first-party Embedded matrix runs post-flip |

---

## Stability

Pre-1.0. The public API of `Sequence` and its members may change before 0.1.0 is tagged; consumers depending on `branch: "main"` should expect breaking changes to surface in commit messages and the audit trail under `Audits/`. Once tagged, the package follows the institute SemVer convention: post-1.0 breaking changes ship behind a major bump.

The package is sync-only by design. `Sequence.Protocol` carries no async surface; async iteration is a separate concern handled at a higher layer (the swift-foundations rendering context, etc.). The 6.4-dev nightly RegionIsolation diagnostic is treated as advisory rather than blocking — the run-level conclusion of the post-flip CI matrix is the public stability gate.

---

## Related Packages

Direct dependencies:

- [swift-index-primitives](https://github.com/swift-primitives/swift-index-primitives) — `Index<Element>`, `Ordinal`, `Cardinal` (via index's re-export chain), the typed-indexing surface the iterator family builds on.
- [swift-property-primitives](https://github.com/swift-primitives/swift-property-primitives) — `Property<Tag, Base>` and `Property.Inout`, the phantom-tagged fluent-accessor machinery that powers `.contains { }`, `.count.where { }`, `.forEach.borrowing { }`, and the rest of the terminal surface.

Cohort siblings (Story 2 — Typed indexing and sequences):

- order, index, **sequence**, collection, input, cyclic, vector — see [`data-structures-launch-2026`](https://github.com/swift-institute) for the cohort narrative.

Story 1 sibling primitives ([`cardinal`](https://github.com/swift-primitives/swift-cardinal-primitives), [`ordinal`](https://github.com/swift-primitives/swift-ordinal-primitives), [`affine`](https://github.com/swift-primitives/swift-affine-primitives)) shipped 2026-05-12 and supply the counting / position / displacement primitives that Story 2 builds on.

---

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
