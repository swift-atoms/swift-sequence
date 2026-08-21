public import Iterator_Chunk_Primitives

extension Sequence.Drop.First
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Drop.First` using the forward-to-base
    /// strategy.
    ///
    /// Two phases:
    /// 1. **Skip phase**: Advances past the first N elements without
    ///    returning them.
    /// 2. **Forward phase**: Forwards all subsequent elements directly
    ///    from the base iterator.
    ///
    /// Zero allocation — element-preserving. No heap buffer, no
    /// `deinit` needed for buffer management.
    ///
    /// ## Two iteration tiers
    ///
    /// Conforms unconditionally to the scalar `Iterator.`Protocol`` (via the
    /// tuned `next()` below). It additionally conforms to the bulk
    /// `Iterator.Chunk.`Protocol`` **only when the base iterator is bulk**
    /// (§9 conditional-bulk).
    ///
    /// ## Suppression
    ///
    /// Still `~Copyable` and `~Escapable` because it stores a
    /// `~Copyable` base iterator and has lifetime dependency on it —
    /// not because of any `deinit`.
    ///
    /// ## Extension `where` Clause
    ///
    /// The `where Base: ~Copyable & ~Escapable` on this extension is
    /// required — same as `Map.Iterator`. Nested types in separate
    /// extension files must use the same `where` clause as the
    /// conformance extension.
    public struct Iterator: ~Copyable, ~Escapable,
        Iterator_Primitive.Iterator.`Protocol`<Base.Element, Base.Iterator.Failure>
    {
        @_implements(Iterator_Primitive.Iterator.`Protocol`, Element)
        public typealias ScalarElement = Base.Element

        @_implements(Iterator_Primitive.Iterator.`Protocol`, Failure)
        public typealias ScalarFailure = Base.Iterator.Failure

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        var _remaining: Cardinal

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _remaining: Cardinal) {
            self._base = _base
            self._remaining = _remaining
        }
    }
}

extension Sequence.Drop.First.Iterator
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {
    /// Returns the next base element after the drop phase, or `nil` when iteration completes.
    ///
    /// Tuned scalar override (preserved per the migration perf invariant): drives the base's
    /// scalar `next()` directly during the skip phase rather than routing through the foundation
    /// default `next(maximumCount: 1)`.
    @_lifetime(&self)
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        while _remaining > .zero {
            _remaining = _remaining.subtract.saturating(.one)
            switch try _base.next() {
            case .none: return nil
            case .some: continue
            }
        }
        return try _base.next()
    }
}

// Bulk tier — conditional on the base being bulk (§9 conditional-bulk).
extension Sequence.Drop.First.Iterator:
    Iterator_Primitive.Iterator.Chunk.`Protocol`<Base.Element, Base.Iterator.Failure>
where
    Base: ~Copyable & ~Escapable,
    Base.Element: Escapable,
    Base.Iterator: Iterator_Primitive.Iterator.Chunk.`Protocol`<
        Base.Element, Base.Iterator.Failure
    >
{
    @_implements(__IteratorChunkProtocol, Element)
    public typealias ChunkElement = Base.Element

    @_implements(__IteratorChunkProtocol, Failure)
    public typealias ChunkFailure = Base.Iterator.Failure

    /// Returns the next batch of base elements after the drop phase, forwarding the base's bulk spans.
    ///
    /// The skip phase consumes (and discards) leading spans rather than relying on a base
    /// `skip(by:)` (the foundation bulk protocol has none).
    @_lifetime(&self)
    @inlinable
    public mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Base.Iterator.Failure) -> Swift.Span<Base.Element> {
        let maximumCount = maximumCount.underlying
        while _remaining > .zero {
            let span = try _base.next(maximumCount: _remaining)
            if span.isEmpty {
                return span
            }
            _remaining = _remaining.subtract.saturating(Cardinal(UInt(span.count)))
        }
        return try _base.next(maximumCount: maximumCount)
    }
}
