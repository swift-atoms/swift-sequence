public import Iterator_Chunk_Primitives

extension Sequence.Prefix.First
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Prefix.First` using the forward-to-base
    /// strategy.
    ///
    /// Forwards base elements while a remaining count is positive, decrementing
    /// the count each step and stopping once it reaches zero.
    ///
    /// Zero allocation — element-preserving.
    ///
    /// ## Two iteration tiers
    ///
    /// Conforms unconditionally to the scalar `Iterator.`Protocol`` (via the
    /// tuned `next()` below). It additionally conforms to the bulk
    /// `Iterator.Chunk.`Protocol`` **only when the base iterator is bulk**
    /// (§9 conditional-bulk), forwarding clamped sub-spans.
    ///
    /// ## Suppression
    ///
    /// `~Copyable` and `~Escapable` because it stores a `~Copyable`
    /// base iterator and has lifetime dependency on it.
    ///
    /// ## Extension `where` Clause
    ///
    /// The `where Base: ~Copyable & ~Escapable` on this extension is
    /// required — same as `Map.Iterator`.
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

extension Sequence.Prefix.First.Iterator
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {
    /// The element type produced by this iterator (the first N elements of the base).
    /// Returns the next prefix element, or `nil` when the prefix count is exhausted.
    ///
    /// Tuned scalar override (preserved per the migration perf invariant).
    @_lifetime(&self)
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        guard _remaining > .zero else { return nil }
        _remaining = _remaining.subtract.saturating(.one)
        return try _base.next()
    }
}

// Bulk tier — conditional on the base being bulk (§9 conditional-bulk).
extension Sequence.Prefix.First.Iterator:
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

    /// Returns the next batch of prefix elements, bounded by the remaining count.
    @_lifetime(&self)
    @inlinable
    public mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Base.Iterator.Failure) -> Swift.Span<Base.Element> {
        let maximumCount = maximumCount.underlying
        guard _remaining > .zero else {
            return try _base.next(maximumCount: Cardinal.zero)
        }
        let clamped = min(maximumCount, _remaining)
        let span = try _base.next(maximumCount: clamped)
        _remaining = _remaining.subtract.saturating(Cardinal(UInt(span.count)))
        return span
    }
}
