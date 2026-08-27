# Sequence

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Move-only-capable sequence primitives for Swift. The package defines `Sequenceable`,
lazy map/filter/flatMap/drop/prefix adapters, terminal operations, borrowing and
draining refinements, and a Myers difference implementation.

`Sequenceable` is separate from `Swift.Sequence`: its element and iterator can be
`~Copyable`, allowing one-shot streams and ownership-sensitive values to participate
in the same composition model.

## Installation

```swift
dependencies: [
    .package(
        url: "https://github.com/swift-atoms/swift-sequence.git",
        branch: "main"
    ),
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Sequence", package: "swift-sequence"),
    ]
)
```

The package uses Swift tools 6.4 and currently declares the version-27 Apple
platform baselines.

## Products

The atom has exactly three library products:

- `Sequence` contains the Foundation-free core, including `Sequenceable`, iterator
  adapters, terminal operations, borrowing/draining protocols, and difference types.
- `Sequence Standard Library Integration` adds `Swift.Span.Iterator`, its batch
  variant, and standard-library conveniences.
- `Sequence Apple Foundation Integration` is the only target that imports
  Foundation and composes the core and standard-library integration products.

Choose the narrowest product your target needs. Most consumers should depend on
`Sequence`; add an integration product only at the corresponding boundary.

## Core protocol

```swift
public protocol Sequenceable<Element>: ~Copyable, ~Escapable {
    associatedtype Element: ~Copyable & ~Escapable
    associatedtype Iterator: Iterating, ~Copyable, ~Escapable
        where Iterator.Element == Element

    consuming func makeIterator() -> Iterator
}
```

The iterator contract comes from the consolidated `Iterator` product. Chunk-capable
borrowing sequences use the current iterator chunk protocol and take `Cardinal`
maximum counts.

## Difference example

```swift
import Sequence

let changes = Sequence.Difference.diff(
    ["one", "two", "three"],
    ["one", "second", "three"]
)
let counts = changes.counts()
print(counts.removed.rawValue, counts.inserted.rawValue)
```

`Sequence.Difference` also exposes steps, change counts, and unified-diff-style
hunks with `Ordinal` positions and `Cardinal` counts.

## Dependencies

The core depends directly on the canonical atom homes:

- [swift-iterator](https://github.com/swift-atoms/swift-iterator)
- [swift-cardinal](https://github.com/swift-atoms/swift-cardinal)
- [swift-ordinal](https://github.com/swift-atoms/swift-ordinal)

## Status

Pre-1.0. Public API may change while dependencies track `main`.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
