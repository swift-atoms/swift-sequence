public import Iterator

extension Sequence.Difference.Changes {

    public struct Iterator: Iterating {
        @usableFromInline
        var _storage: [Sequence.Difference.Change<Value>]

        @usableFromInline
        var _index: Int

        @usableFromInline
        let _count: Int

        @inlinable
        package init(_ storage: [Sequence.Difference.Change<Value>]) {
            self._storage = storage
            self._index = 0
            self._count = storage.count
        }
    }
}

extension Sequence.Difference.Changes.Iterator {

    @inlinable
    public mutating func next() -> Sequence.Difference.Change<Value>? {
        guard _index < _count else { return nil }
        defer { _index += 1 }
        return _storage[_index]
    }
}
