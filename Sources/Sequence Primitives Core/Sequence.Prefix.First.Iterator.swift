public import Index_Primitives

extension Sequence.Prefix.First where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Prefix.First` using the forward-to-base
    /// strategy.
    ///
    /// Forwards `nextSpan` to the base with
    /// `min(maximumCount, _remaining)`. Decrements `_remaining` by
    /// the span count. Returns the base's empty span once the count
    /// is exhausted.
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
        public typealias Element = Base.Element

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        var _remaining: Cardinal

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base.Iterator, _remaining: Cardinal) {
            self._base = _base
            self._remaining = _remaining
        }

        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Base.Element> {
            guard _remaining > .zero else {
                return _base.nextSpan(maximumCount: .zero)
            }
            let clamped = min(maximumCount, _remaining)
            let span = _base.nextSpan(maximumCount: clamped)
            _remaining = _remaining.subtract.saturating(Cardinal(UInt(span.count)))
            return span
        }

        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Base.Element? where Base.Element: Copyable {
            guard _remaining > .zero else { return nil }
            _remaining = _remaining.subtract.saturating(.one)
            return _base.next()
        }
    }
}
