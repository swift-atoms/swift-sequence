# Lazy Pipelines

@Metadata {
    @TitleHeading("Sequence Primitives")
}

The closed algebra of lazy wrappers — `map`, `filter`, `flatMap`, `compactMap`, `drop`, `prefix` — and their iterator implementations.

## Overview

A lazy wrapper takes a `Sequence.Protocol` conformer and produces another `Sequence.Protocol` conformer with the operation applied lazily — no element copies, no buffers, no work until a terminal operation consumes the chain. Each wrapper is its own type, parameterized over the base sequence, and conforms to `Sequence.Protocol` so chaining composes uniformly.

```swift
let pipeline = source
    .map { $0 * 2 }
    .filter { $0 > 10 }
    .prefix(first: Cardinal(3))

let result = pipeline.collect()  // first 3 elements where 2× value > 10
```

Six operations form the closed algebra:

| Operation | Wrapper type | What it produces |
|-----------|--------------|-------------------|
| `map { }` | `Sequence.Map<Base, Output>` | Transforms each element. |
| `filter { }` | `Sequence.Filter<Base>` | Yields only elements satisfying the predicate. |
| `flatMap { }` | `Sequence.FlatMap<Base, InnerSequence>` | Transforms each element to an inner sequence; flattens. |
| `compactMap { }` | `Sequence.CompactMap<Base, Output>` | Transforms; skips `nil` results. |
| `drop(first:)` / `drop(while:)` | `Sequence.Drop.First<Base>` / `Sequence.Drop.While<Base>` | Skips leading elements by count or predicate. |
| `prefix(first:)` / `prefix(while:)` | `Sequence.Prefix.First<Base>` / `Sequence.Prefix.While<Base>` | Takes leading elements by count or predicate. |

Each wrapper has an associated `Iterator` type implementing one of two strategies described below.

## The two iterator strategies

### Strategy A: Optional inline buffer (generating iterators)

Iterators that produce elements one at a time — `Map`, `Filter`, `CompactMap`, `FlatMap` — store a `var _element: Output? = nil` as inline deferred-initialization storage. The Optional payload sits at byte offset 0 (an ABI guarantee for single-payload enums), enabling `withUnsafeMutablePointer` + `assumingMemoryBound` to produce a valid `Span<Output>` pointing at the inline slot. Zero heap allocation.

```swift
@_lifetime(&self)
public mutating func nextSpan(maximumCount: Cardinal) -> Span<Output> {
    let ptr = unsafe withUnsafeMutablePointer(to: &_element) { p in
        unsafe UnsafePointer<Output>(
            unsafe UnsafeRawPointer(p).assumingMemoryBound(to: Output.self)
        )
    }
    guard maximumCount > .zero,
          let element = _base.next() else {
        let span = unsafe Span(_unsafeStart: ptr, count: 0)
        return unsafe _overrideLifetime(span, mutating: &self)
    }
    _element = _transform(element)
    let span = unsafe Span(_unsafeStart: ptr, count: 1)
    return unsafe _overrideLifetime(span, mutating: &self)
}
```

The pattern's correctness and performance are documented in `Research/zero-allocation-nextspan-for-generating-iterators.md` (the design decision) and verified by experiments under `Experiments/inline-rawlayout-nextspan/` and `Experiments/nextspan-performance-overhead/`.

`next()` is overridden in each generating iterator for a performance-critical fast path that returns the transformed value directly without constructing a span.

### Strategy B: Forward-to-base (element-preserving iterators)

Iterators that preserve elements without transformation — `Drop.First`, `Drop.While`, `Prefix.First`, `Prefix.While` — forward `nextSpan` calls directly to the base iterator with adjusted bounds. Zero allocation, zero buffer, zero deinit needed.

`Drop.First` operates in two phases: a skip phase that advances past the first N elements via `_base.skip(by:)`, then a forward phase that proxies all subsequent calls. `Drop.While` similarly scans base spans for the first element failing the predicate, returns the sub-span from that point via `extracting(droppingFirst:)`, then forwards.

`Prefix.First` forwards `nextSpan` with `min(maximumCount, _remaining)` and decrements `_remaining` by the returned span's count. `Prefix.While` scans for the first failing element and returns the prefix via `extracting(first:)`.

## Full suppression pattern

Every lazy wrapper carries the same suppression dance:

1. **Generic constraint** — `Base` suppresses both: `Base: Sequence.Protocol & ~Copyable & ~Escapable`
2. **`@_lifetime` on init** — wrapper lifetime derived from base: `@_lifetime(copy _base)`
3. **Conditional conformance restoration** with cross-constraints:
   ```swift
   extension Sequence.Map: Copyable where Base: Copyable & ~Escapable {}
   extension Sequence.Map: Escapable where Base: Escapable & ~Copyable {}
   ```
   The `& ~Escapable` cross-constraint on `Copyable` prevents circular conformance inference.
4. **Conformance extension** with `where Base: ~Copyable & ~Escapable` — required even though the struct already has those constraints, because conditional conformance widens the context.

`Sequence.Map` is the canonical demonstration; the other five wrappers follow the same shape with adjustments for their specific surface (e.g., `CompactMap` adds `Base.Element: Copyable`, `FlatMap` adds `InnerSequence.Element: Copyable` and `InnerSequence.Iterator: Escapable`).

## FlatMap state-machine quirk

`Sequence.FlatMap.Iterator` is the one wrapper with a state-machine quirk: it stores `var _inner: InnerSequence.Iterator?` as the current inner iterator. The natural pattern would be:

```swift
if var inner = _inner {
    if let element = inner.next() { ... }
    _inner = inner
}
```

But this consumes `_inner` for `~Copyable` inner iterators, causing "cannot partially reinitialize self." The actual pattern uses force-unwrap to mutate in place without consuming:

```swift
if _inner != nil {
    // swift-format-ignore: NeverForceUnwrap
    if let element = _inner!.next() { ... }
}
```

The two force-unwrap sites carry `// swift-format-ignore: NeverForceUnwrap` directives; the type-level doc comment documents the constraint. Experiment `flatmap-inner-iterator-state-machine` (V3 REFUTED, V1 CONFIRMED) captures the design exploration.
