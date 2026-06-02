//
//  Sequence.Difference.Steps.Iterator.swift
//  swift-sequence-primitives
//
//  Iterator for Sequence.Difference.Steps.
//

extension Sequence.Difference.Steps {
    /// Iterator producing ``Step`` elements one at a time.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        var _storage: [Sequence.Difference.Step]

        @usableFromInline
        var _index: Ordinal

        @usableFromInline
        let _count: Cardinal

        @inlinable
        package init(_ storage: [Sequence.Difference.Step]) {
            self._storage = storage
            self._index = .zero
            self._count = Cardinal(UInt(storage.count))
        }
    }
}

extension Sequence.Difference.Steps.Iterator {
    /// Returns the next edit step, or `nil` when iteration completes.
    @inlinable
    public mutating func next() -> Sequence.Difference.Step? {
        guard _index < _count else { return nil }
        defer { _index = _index.successor.saturating() }
        return _storage[_index]
    }
}
