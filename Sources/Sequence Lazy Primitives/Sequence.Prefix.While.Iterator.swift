public import Index_Primitives

extension Sequence.Prefix.While where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Prefix.While` using the forward-to-base
    /// strategy.
    ///
    /// Scans base spans for the first element failing the predicate.
    /// Returns the prefix sub-span via `extracting(first:)`, then
    /// returns empty spans for all subsequent calls.
    ///
    /// Zero allocation — element-preserving.
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
    public struct Iterator: ~Copyable, ~Escapable, Sequence.Iterator.`Protocol` {
        /// The element type produced by this iterator (base elements while the predicate holds).
        public typealias Element = Base.Element

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @usableFromInline
        var _done: Bool

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
            self._done = false
        }

        /// Returns the next batch of prefix elements, stopping at the first element where the predicate fails.
        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Base.Element> {
            guard !_done else {
                return _base.nextSpan(maximumCount: .zero)
            }
            let span = _base.nextSpan(maximumCount: maximumCount)
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

        /// Returns the next prefix element, or `nil` once the predicate first fails.
        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Base.Element? {
            guard !_done else { return nil }
            guard let element = _base.next() else { return nil }
            if _predicate(element) {
                return element
            }
            _done = true
            return nil
        }
    }
}
