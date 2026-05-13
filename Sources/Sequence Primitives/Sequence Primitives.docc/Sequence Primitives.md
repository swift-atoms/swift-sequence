# ``Sequence_Primitives``

@Metadata {
    @DisplayName("Sequence Primitives")
    @TitleHeading("Swift Institute — Primitives Layer")
}

Iterator and sequence primitives for Swift — `Sequence.Protocol` with `~Copyable` element support, lazy `map`/`filter`/`flatMap`/`prefix`/`drop` pipelines, terminal operations via the fluent `.<op>` Property.Inout surface, and a Myers-difference implementation.

## Overview

Stdlib's `Swift.Sequence` requires `Element: Copyable` (per SE-0427). `Sequence_Primitives` lifts that constraint: `Sequence.Protocol` declares `associatedtype Element: ~Copyable`, the entire iterator family is `~Copyable & ~Escapable`, and every lazy wrapper propagates the constraint via `borrowing` closure parameters. Move-only and lifetime-bound element types — `Span<T>`, file descriptors, unique resource handles — are first-class.

The package's signature primitive is `nextSpan(maximumCount:)`: every iterator returns a borrowed sub-span into its internal storage rather than producing owned elements one at a time. `next() -> Element?` is a convenience built on top. The pattern enables zero-allocation iteration through generating wrappers like `Sequence.Map` and `Sequence.Filter` via an inline-stored `Optional<Element>` buffer.

Sequence is a node within **Story 2 of the data-structures cohort** (`data-structures-launch-2026`): seven packages introducing typed indexing and sequences — order, index, **sequence**, collection, input, cyclic, vector. Story 1 (cardinal, ordinal, affine) shipped 2026-05-12. The direct dependencies — `Index_Primitives` and `Property_Primitives` — are honest: removing index breaks the `Cardinal` / `Ordinal` surface the iterator family builds on (re-exported through index's umbrella), and removing property breaks the `.contains { }` / `.count.where { }` / `.forEach.borrowing { }` terminal-accessor surface.

## Topics

### Essentials

- <doc:Architecture>
- <doc:Sequence-Protocol>
- <doc:Lazy-Pipelines>
- <doc:Terminal-Operations>
- <doc:Difference>
