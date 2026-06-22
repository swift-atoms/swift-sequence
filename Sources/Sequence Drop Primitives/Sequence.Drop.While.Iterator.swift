public import Iterator_Chunk_Primitives

extension Sequence.Drop.While where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Drop.While` using the forward-to-base
    /// strategy.
    ///
    /// Two phases:
    /// 1. **Drop phase**: Scans base elements for the first one
    ///    failing the predicate.
    /// 2. **Forward phase**: Forwards all subsequent elements directly
    ///    from the base iterator.
    ///
    /// Zero allocation — element-preserving.
    ///
    /// ## Two iteration tiers
    ///
    /// Conforms unconditionally to the scalar `Iterator.`Protocol`` (via the
    /// tuned `next()` below). It additionally conforms to the bulk
    /// `Iterator.Chunk.`Protocol`` **only when the base iterator is bulk**
    /// (§9 conditional-bulk): `drop(while:)` over a contiguous source forwards
    /// spans; over a scalar source it stays scalar.
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
    public struct Iterator: ~Copyable, ~Escapable, Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @usableFromInline
        var _dropping: Bool

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
            self._dropping = true
        }
    }
}

extension Sequence.Drop.While.Iterator where Base: ~Copyable & ~Escapable {
    /// The element type produced by this iterator (forwarded from the base after the drop phase).
    public typealias Element = Base.Element

    /// Returns the next base element once the predicate first fails, or `nil` when iteration completes.
    ///
    /// Tuned scalar override (preserved per the migration perf invariant): drives the base's
    /// scalar `next()` directly rather than routing through the foundation default
    /// `next(maximumCount: 1)`.
    @_lifetime(&self)
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        while let element = try _base.next() {
            if _dropping && _predicate(element) {
                continue
            }
            _dropping = false
            return element
        }
        return nil
    }
}

// Bulk tier — conditional on the base being bulk (§9 conditional-bulk).
extension Sequence.Drop.While.Iterator: Iterator.Chunk.`Protocol`
where Base: ~Copyable & ~Escapable, Base.Iterator: Iterator.Chunk.`Protocol` {
    /// Returns the next batch of base elements once the predicate first fails, forwarding the
    /// base's bulk spans.
    @_lifetime(&self)
    @inlinable
    public mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Base.Iterator.Failure) -> Swift.Span<Base.Element> {
        let maximumCount = maximumCount.underlying
        if !_dropping {
            return try _base.next(maximumCount: maximumCount)
        }
        while _dropping {
            let span = try _base.next(maximumCount: maximumCount > .zero ? maximumCount : .max)
            if span.isEmpty { return span }
            for i in span.indices {
                if !_predicate(span[i]) {
                    _dropping = false
                    return span.extracting(droppingFirst: i)
                }
            }
        }
        return try _base.next(maximumCount: Cardinal.zero)
    }
}
