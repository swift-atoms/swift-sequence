public import Cardinal
public import Cardinal_Carrier
public import Iterator_Protocol
public import Ordinal
public import Ordinal_Protocol
public import Ordinal_Standard_Library_Integration
public import Ordinal_Successor

extension Sequence.Difference.Steps {

    public struct Iterator: Iterator::Iterator.`Protocol` {
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

    @inlinable
    public mutating func next() -> Sequence.Difference.Step? {
        guard _index.rawValue < _count.rawValue else { return nil }
        defer { _index = _index.successor.saturating() }
        return _storage[_index]
    }
}
