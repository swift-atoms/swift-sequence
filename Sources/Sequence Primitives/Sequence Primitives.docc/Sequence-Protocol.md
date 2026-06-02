# Sequence Protocol

@Metadata {
    @TitleHeading("Sequence Primitives")
}

The `~Copyable`-friendly sequence protocol family — `Sequence.Protocol`, `Sequence.Iterator.Protocol`, `Sequence.Borrowing.Protocol`.

## Overview

The protocol family is the foundation every other surface in this package builds on. Three sibling protocols define the contract:

- `Sequence.Protocol` — a type that can produce an iterator. Once-shot: making an iterator typically consumes the sequence.
- `Sequence.Iterator.Protocol` — the iterator itself. Yields elements via `nextSpan(maximumCount:)` (primitive) or `next()` (default-implemented convenience).
- `Sequence.Borrowing.Protocol` — a refinement for types that can be iterated multiple times via borrowed references (the original is preserved, not consumed).

All three protocols declare `associatedtype Element: ~Copyable`. The suppression flows through the chain: iterators are `~Copyable & ~Escapable`, closures over elements take `borrowing` parameters, and span-typed return values carry the lifetime of the iterator state. `~Escapable` relaxation on `Element` is blocked upstream — `Swift.Span<Element>` requires `Element: Escapable` (Swift 6.3.1 through 6.5-dev). See `Research/element-tilde-escapable-stdlib-span-blocker.md`.

## The `Copyable` delta

`Swift.Sequence.Element` is constrained to `Copyable` per SE-0427. That closes off iteration over move-only types — there is no way to express "a sequence of file descriptors" or "a sequence of unique resource handles" through stdlib's protocol.

`Sequence.Protocol` lifts the constraint:

```swift
public protocol `Protocol`<Element>: ~Copyable, ~Escapable {
    associatedtype Element: ~Copyable
    associatedtype Iterator: Sequence.Iterator.`Protocol` & ~Copyable & ~Escapable
        where Iterator.Element == Element

    @_lifetime(copy self)
    consuming func makeIterator() -> Iterator
}
```

The `~Copyable` suppression on `Element` means a conformer can produce iterators over move-only types. The `consuming func makeIterator()` is the once-shot contract: handing ownership of the sequence to the iterator. Types that need multi-pass iteration conform to `Sequence.Borrowing.Protocol` instead, which yields an iterator from a borrowed `self` and preserves the original.

## `nextSpan(maximumCount:)` as the primitive method

Every iterator implements `nextSpan(maximumCount:) -> Span<Element>` as the primitive method:

```swift
public protocol `Protocol`<Element>: ~Copyable, ~Escapable {
    associatedtype Element: ~Copyable

    @_lifetime(&self)
    mutating func nextSpan(maximumCount: Cardinal) -> Span<Element>

    // Default-implemented; iterators may override for performance.
    mutating func next() -> Element? where Element: Copyable
}
```

The contract: each call returns a borrowed span into the iterator's internal storage. The caller may consume the span in place; the next call invalidates the previous return value. An empty span signals end-of-iteration.

This is the moral equivalent of stdlib's `withContiguousStorageIfAvailable`, lifted to the iterator level and made unconditional rather than opportunistic. For container-backed sequences the span points directly at the container's storage (zero indirection). For generating sequences (`Map`, `Filter`, etc.) the span points at an inline-stored `Optional<Element>` buffer (one element at a time, but zero heap allocation).

`next()` is a default-implemented convenience built on top of `nextSpan(maximumCount: 1)`. Iterators may override `next()` for performance — `Map.Iterator` and the rest of the lazy family do, returning the transformed value directly without constructing a single-element span.

## Primary associated type promotion

All three protocols declare `Element` as a **primary associated type** (PAT) per SE-0346:

```swift
public protocol `Protocol`<Element>: ~Copyable, ~Escapable { ... }
```

The promotion unlocks the constrained-opaque-return-type shape:

```swift
func nodes() -> some Sequence.`Protocol`<Node>
```

This is additive: every existing `extension where Element == X` continues to type-check unchanged.

## Sample conformer

A minimal conformer backed by `Swift.Array`:

```swift
import Sequence_Primitives

struct MyContainer<Element>: Sequence.`Protocol` {
    let elements: [Element]

    consuming func makeIterator() -> Iterator {
        Iterator(elements)
    }

    struct Iterator: Sequence.Iterator.`Protocol` {
        var elements: [Element]
        var position: Int = 0

        @_lifetime(&self)
        mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Element> {
            let remaining = elements.count - position
            let take = min(Int(maximumCount.rawValue), remaining)
            guard take > 0 else { return elements.span.extracting(first: 0) }
            let result = elements.span
                .extracting(droppingFirst: position)
                .extracting(first: take)
            position += take
            return result
        }
    }
}
```

For `~Copyable` element types, the same shape works — the iterator stores a `~Copyable` backing source and the `nextSpan` return type carries the element constraint through.

## Borrowing variant

`Sequence.Borrowing.Protocol` is for types that need to be iterated multiple times without being consumed:

```swift
public protocol `Protocol`<Element>: ~Copyable, ~Escapable {
    associatedtype Element: ~Copyable
    associatedtype Iterator: Sequence.Iterator.`Protocol` & ~Copyable & ~Escapable
        where Iterator.Element == Element

    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator
}
```

The signature difference is `borrowing func makeIterator()` instead of `consuming`. The original sequence is preserved; the iterator carries a `borrowed` lifetime tied to the source. Multi-pass iteration becomes expressible without forfeit of ownership.

## Conformance to `Swift.Sequence`

A dual-conformance bridge in `Sequence Standard Library Integration` lets types conforming to both `Sequence.Protocol` and `Swift.Sequence` interoperate. The bridge installs an `@inline(always) forEach` that wins overload resolution against `Swift.Sequence.forEach`, forcing closure inlining during mandatory SIL passes — this matters for `~Copyable` classes whose deinits cannot tolerate `partial_apply` lifetime tracking.
