//
//  Sequence.Difference.Steps.Iterator.swift
//  swift-sequence-primitives
//
//  Iterator for Sequence.Difference.Steps.
//

extension Sequence.Difference.Steps {
    /// Iterator producing ``Step`` elements via span-based batching.
    public struct Iterator: Sequence.Iterator.`Protocol` {
        @usableFromInline
        var _storage: [Sequence.Difference.Step]

        @usableFromInline
        var _index: Int

        @inlinable
        init(_ storage: [Sequence.Difference.Step]) {
            self._storage = storage
            self._index = 0
        }

        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Sequence.Difference.Step> {
            let remaining = _storage.count - _index
            let take = min(Int(maximumCount.rawValue), remaining)
            guard take > 0 else { return _storage.span.extracting(first: 0) }
            let start = _index
            _index += take
            return _storage.span
                .extracting(droppingFirst: start)
                .extracting(first: take)
        }

        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Sequence.Difference.Step? {
            guard _index < _storage.count else { return nil }
            defer { _index += 1 }
            return _storage[_index]
        }
    }
}
