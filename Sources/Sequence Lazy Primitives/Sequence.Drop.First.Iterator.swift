public import Index_Primitives

extension Sequence.Drop.First where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Drop.First` using the forward-to-base
    /// strategy.
    ///
    /// Two phases:
    /// 1. **Skip phase**: Uses `_base.skip(by:)` to advance past the
    ///    first N elements without returning them.
    /// 2. **Forward phase**: Passes all subsequent `nextSpan` calls
    ///    directly to the base iterator.
    ///
    /// Zero allocation — element-preserving. No heap buffer, no
    /// `deinit` needed for buffer management.
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
    ///
    /// ## `next()` Override
    ///
    /// Overrides the default for performance. Loops through elements
    /// one-by-one during the skip phase, then forwards to
    /// `_base.next()`.
    public struct Iterator: ~Copyable, ~Escapable, Sequence.Iterator.`Protocol` {
        /// The element type produced by this iterator (forwarded from the base).
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

        /// Returns the next batch of base elements after the initial drop count is exhausted.
        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Base.Element> {
            if _remaining > .zero {
                let skipped = _base.skip(by: _remaining)
                _remaining = _remaining.subtract.saturating(skipped)
                if _remaining > .zero {
                    return _base.nextSpan(maximumCount: .zero)
                }
            }
            return _base.nextSpan(maximumCount: maximumCount)
        }

        /// Returns the next base element after the drop phase, or `nil` when iteration completes.
        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Base.Element? where Base.Element: Copyable {
            while _remaining > .zero {
                _remaining = _remaining.subtract.saturating(.one)
                guard _base.next() != nil else { return nil }
            }
            return _base.next()
        }
    }
}
