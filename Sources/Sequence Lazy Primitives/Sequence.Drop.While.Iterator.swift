public import Index_Primitives

extension Sequence.Drop.While where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Drop.While` using the forward-to-base
    /// strategy.
    ///
    /// Two phases:
    /// 1. **Drop phase**: Scans base spans for the first element
    ///    failing the predicate, returns the sub-span from that point
    ///    via `extracting(droppingFirst:)`.
    /// 2. **Forward phase**: Passes all subsequent `nextSpan` calls
    ///    directly to the base iterator.
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
        /// The element type produced by this iterator (forwarded from the base after the drop phase).
        public typealias Element = Base.Element

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @usableFromInline
        var _dropping: Bool

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
            self._dropping = true
        }

        /// Returns the next batch of base elements once the predicate first fails.
        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Base.Element> {
            if !_dropping {
                return _base.nextSpan(maximumCount: maximumCount)
            }
            while _dropping {
                let span = _base.nextSpan(maximumCount: maximumCount > .zero ? maximumCount : .max)
                if span.isEmpty { return span }
                for i in span.indices {
                    if !_predicate(span[i]) {
                        _dropping = false
                        return span.extracting(droppingFirst: i)
                    }
                }
            }
            return _base.nextSpan(maximumCount: .zero)
        }

        /// Returns the next base element once the predicate first fails, or `nil` when iteration completes.
        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Base.Element? {
            while let element = _base.next() {
                if _dropping && _predicate(element) {
                    continue
                }
                _dropping = false
                return element
            }
            return nil
        }
    }
}
