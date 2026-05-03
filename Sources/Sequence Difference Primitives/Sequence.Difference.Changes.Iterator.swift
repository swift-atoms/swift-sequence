//
//  Sequence.Difference.Changes.Iterator.swift
//  swift-sequence-primitives
//
//  Iterator for Sequence.Difference.Changes.
//

extension Sequence.Difference.Changes {
    /// Iterator producing ``Change`` elements via span-based batching.
    public struct Iterator: Sequence.Iterator.`Protocol` {
        @usableFromInline
        var _storage: [Sequence.Difference.Change<Value>]

        @usableFromInline
        var _index: Ordinal

        @usableFromInline
        let _count: Cardinal

        @inlinable
        init(_ storage: [Sequence.Difference.Change<Value>]) {
            self._storage = storage
            self._index = .zero
            self._count = Cardinal(UInt(storage.count))
        }

        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Sequence.Difference.Change<Value>> {
            let remaining = _count.subtract.saturating(Cardinal(_index))
            let take = min(maximumCount, remaining)
            guard take > .zero else { return _storage.span.extracting(first: 0) }
            let start = Int(bitPattern: _index)
            let count = Int(bitPattern: take)
            let result = _storage.span
                .extracting(droppingFirst: start)
                .extracting(first: count)
            _index = _index.advance.saturating(by: take)
            return result
        }

        @inlinable
        public mutating func next() -> Sequence.Difference.Change<Value>? {
            guard Cardinal(_index) < _count else { return nil }
            defer { _index = _index.successor.saturating() }
            return _storage[_index]
        }
    }
}
