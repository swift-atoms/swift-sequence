# Sequence Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Iterator and sequence primitives for Swift — `Sequence.Protocol` with `~Copyable` element support, lazy map/filter/flatMap/prefix/drop pipelines, terminal operations via fluent `.<op>` accessors, and a Myers-difference implementation.

Stdlib's `Swift.Sequence` requires `Element: Copyable` (per SE-0427). `Sequence.Protocol` in this package lifts that constraint so move-only element types — file descriptors, unique resource handles, one-shot generator state — can be iterated without being copied. The protocol family pairs with a `nextSpan(maximumCount:)` primitive that returns borrowed sub-spans into the source, enabling batch iteration without an intermediate heap allocation per element.

`~Escapable` element relaxation (e.g., `Span<T>` as an `Element`) is blocked upstream until `Swift.Span<Element>` accepts `Element: ~Escapable`. See `Research/element-tilde-escapable-stdlib-span-blocker.md` for the language-level constraint.

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

// Terminal ops — `count` is a direct property, predicates go through fluent accessors
let total       = doubledEvens.count                         // Cardinal(3)
let firstMatch  = doubledEvens.first { $0 > 8 }              // Optional(12)
let anyOver10   = doubledEvens.satisfies.any { $0 > 10 }     // true

// forEach takes the closure directly; .forEach.borrowing { } and
// .forEach.consuming { } are the explicit-ownership variants.
doubledEvens.forEach { element in
    print(element)  // 4, 8, 12
}
```

For `~Copyable` element types, the same pipeline works without copies — `Sequence.Map<Base>.Eager<Output>` carries the `~Copyable` constraint forward through the iterator chain, and the `nextSpan` primitive yields borrowed spans rather than owned elements.

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

The package decomposes into one library product per sub-namespace. Consumers can import the umbrella for the full surface, or pin to specific sub-namespaces to track compile cost.

| Conceptual axis | Library products | What's in it |
|---|---|---|
| Protocol family | `Sequence Namespace`, `Sequence Iterator`, `Sequence Protocol`, `Sequence Borrowing`, `Sequence Span` | The `Sequence.Protocol` family, `Sequence.Iterator.Protocol`, `Sequence.Borrowing.Protocol`, and the `Sequence.Span` integration types. |
| Lazy pipeline | `Sequence Map`, `Sequence Filter`, `Sequence Drop`, `Sequence Prefix` | Lazy wrappers — `Sequence.Map<Base>` (with nested `.Eager`/`.Compact`/`.Flat`), `Sequence.Filter`, `Sequence.Drop.First/While`, `Sequence.Prefix.First/While`. |
| Terminal operations | `Sequence ForEach`, `Sequence Satisfies`, `Sequence Contains`, `Sequence First`, `Sequence Reduce`, `Sequence Hint` | Terminal ops via the fluent `.<op>` Property.Inout surface. `Sequence.Hint` is the namespace for cheap-but-imprecise hints (`hint.count`). |
| Consuming-side | `Sequence Drain` | Draining refinement for `~Copyable` containers. |
| Diff algorithm | `Sequence Difference` | Myers O(ND) diff — `Sequence.Difference`, `Steps`, `Changes`, `Change`, `Hunk`. |
| Stdlib bridges | `Sequence Standard Library Integration` | `Swift.Span.Iterator`, `Swift.Span.Iterator.Batch`, and the `Sequence.Protocol` ⇄ `Swift.Sequence` adapter. |
| Umbrella | `Sequence Primitives` | Re-exports every sub-namespace product. The default for application code. |
| Test infrastructure | `Sequence Primitives Test Support` | Fixture conformers — `Source`, `Clearable.Source`, `Drainable.Source` — for downstream test code. |

Foundation-free across every sub-target. Per-sub-namespace decomposition means an application that only needs `Sequence.Protocol` for its own conforming type imports `Sequence Protocol` and skips compilation of every other surface. Adding a new operation to one axis touches one target; cross-axis composition happens via the umbrella.

Direct counts: 20 library products (5 protocol-family + 4 lazy + 6 terminal + 1 consuming + 1 diff + 1 SLI + 1 umbrella + 1 test support), matching the products declared in `Package.swift`.

---

## `~Copyable` element support

`Sequence.Protocol` declares `associatedtype Element: ~Copyable`. The constraint flows through the entire iterator family — every `Iterator` type is `~Copyable & ~Escapable`, every lazy wrapper preserves the `~Copyable` of the base element via `borrowing` closure parameters, and the `nextSpan(maximumCount:)` primitive returns a `Span<Element>` borrowed from the iterator state rather than an owned collection of elements.

This is the delta against stdlib `Swift.Sequence`: SE-0427 constrained `Swift.Sequence.Element` to `Copyable`, which closes off iteration over move-only types. The protocol family in this package is parameterized so consumers can build sequences over file descriptors, unique resource handles, or any other `~Copyable` type without losing access to the lazy/terminal/diff surface.

For types that need to be iterated without being consumed, `Sequence.Borrowing.Protocol` is the variant: it preserves the original sequence as a borrowed reference, enabling repeated iteration without forfeit of ownership.

---

## `nextSpan(maximumCount:)`

Every iterator in this package implements `nextSpan(maximumCount:) -> Span<Element>` as its primitive method; `next() -> Element?` is a convenience built on top.

The contract: each call returns a borrowed span into the iterator's internal storage (or, for lazy wrappers, the wrapped iterator's storage). The caller may consume the span in place; the next call invalidates the previous return value. This is the moral equivalent of stdlib's `withContiguousStorageIfAvailable`, lifted to the iterator level and made unconditional rather than opportunistic.

Generating iterators that produce one element at a time (`Map.Iterator`, `Filter.Iterator`, `CompactMap.Iterator`, `FlatMap.Iterator`) use an `Optional<Element>` inline-stored buffer and return a 1-element span pointing at the buffer — zero heap allocation, zero copies.

---

## Safety surface

Unsafe surface is concentrated in the SLI bridge to `Swift.Span` and in the inline-buffer pattern used by generating iterators (`@_rawLayout` / `withUnsafeMutablePointer` / `assumingMemoryBound`). Every `@safe`-attributed declaration carries a `## Safety Invariant` section in its doc comment disclosing the invariant relied on; every other `unsafe` site carries an adjacent invariant comment. This document does not state a fixed site count, since the count changes with the source and a stale number is worse than none — search the sources above for the current surface.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Linux | Full support |
| Windows | Full support |
| Swift Embedded | Supported (Wasm SDK + Swift 6.4-dev nightly CI matrix passes) |

---

## Stability

Pre-1.0. The public API of `Sequence` and its members may change while the package remains on `branch: "main"`; consumers should expect breaking changes to surface in commit messages until the first tag. Once tagged, the package follows institute SemVer: post-1.0 breaking changes ship behind a major bump.

The package is sync-only by design. `Sequence.Protocol` carries no async surface; async iteration is a separate concern handled at a higher layer.

---

## Related Packages

Direct dependencies:

- [swift-index-primitives](https://github.com/swift-primitives/swift-index-primitives) — `Index<Element>`, `Ordinal`, `Cardinal` (via index's re-export chain), the typed-indexing surface the iterator family builds on.
- [swift-property-primitives](https://github.com/swift-primitives/swift-property-primitives) — `Property<Tag, Base>` and `Property.Inout`, the phantom-tagged fluent-accessor machinery that powers `.contains { }`, `.satisfies.all { }`, `.forEach.borrowing { }`, and the rest of the terminal surface.

---

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
