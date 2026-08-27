public import Iterator

extension Sequence.Difference.Steps {

    public struct Iterator: Iterating {
        @usableFromInline
        var _storage: [Sequence.Difference.Step]

        @usableFromInline
        var _index: Int

        @usableFromInline
        let _count: Int

        @inlinable
        package init(_ storage: [Sequence.Difference.Step]) {
            self._storage = storage
            self._index = 0
            self._count = storage.count
        }
    }
}

extension Sequence.Difference.Steps.Iterator {

    @inlinable
    public mutating func next() -> Sequence.Difference.Step? {
        guard _index < _count else { return nil }
        defer { _index += 1 }
        return _storage[_index]
    }
}
