public import Iterator_Chunk_Primitives

extension Sequence.Prefix.While where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Prefix.While` using the forward-to-base
    /// strategy.
    ///
    /// Forwards base elements while the predicate holds, stopping at (and not
    /// returning) the first element where the predicate fails.
    ///
    /// Zero allocation — element-preserving.
    ///
    /// ## Two iteration tiers
    ///
    /// Conforms unconditionally to the scalar `Iterator.`Protocol`` (via the
    /// tuned `next()` below). It additionally conforms to the bulk
    /// `Iterator.Chunk.`Protocol`` **only when the base iterator is bulk**
    /// (§9 conditional-bulk): it scans base spans for the first failing element
    /// and returns the prefix sub-span via `extracting(first:)`.
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
        var _done: Bool

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
            self._done = false
        }
    }
}

extension Sequence.Prefix.While.Iterator where Base: ~Copyable & ~Escapable {
    /// The element type produced by this iterator (base elements while the predicate holds).
    public typealias Element = Base.Element

    /// Returns the next prefix element, or `nil` once the predicate first fails.
    ///
    /// Tuned scalar override (preserved per the migration perf invariant).
    @_lifetime(&self)
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        guard !_done else { return nil }
        guard let element = try _base.next() else { return nil }
        if _predicate(element) {
            return element
        }
        _done = true
        return nil
    }
}

// Bulk tier — conditional on the base being bulk (§9 conditional-bulk).
extension Sequence.Prefix.While.Iterator: Iterator.Chunk.`Protocol`
where Base: ~Copyable & ~Escapable, Base.Iterator: Iterator.Chunk.`Protocol` {
    /// Returns the next batch of prefix elements, stopping at the first element where the predicate fails.
    @_lifetime(&self)
    @inlinable
    public mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Base.Iterator.Failure) -> Span<Base.Element> {
        let maximumCount = maximumCount.underlying
        guard !_done else {
            return try _base.next(maximumCount: Cardinal.zero)
        }
        let span = try _base.next(maximumCount: maximumCount)
        if span.isEmpty {
            _done = true
            return span
        }
        for i in span.indices {
            if !_predicate(span[i]) {
                _done = true
                return span.extracting(first: i)
            }
        }
        return span
    }
}
