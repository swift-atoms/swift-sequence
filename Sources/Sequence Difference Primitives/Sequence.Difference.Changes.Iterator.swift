//
//  Sequence.Difference.Changes.Iterator.swift
//  swift-sequence-primitives
//
//  Iterator for Sequence.Difference.Changes.
//

extension Sequence.Difference.Changes {
    /// Iterator producing ``Change`` elements one at a time.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        var _storage: [Sequence.Difference.Change<Value>]

        @usableFromInline
        var _index: Ordinal

        @usableFromInline
        let _count: Cardinal

        @inlinable
        package init(_ storage: [Sequence.Difference.Change<Value>]) {
            self._storage = storage
            self._index = .zero
            self._count = Cardinal(UInt(storage.count))
        }
    }
}

extension Sequence.Difference.Changes.Iterator {
    /// Returns the next element-carrying change, or `nil` when iteration completes.
    @inlinable
    public mutating func next() -> Sequence.Difference.Change<Value>? {
        guard _index < _count else { return nil }
        defer { _index = _index.successor.saturating() }
        return _storage[_index]
    }
}
