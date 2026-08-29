public import Cardinal
public import Cardinal_Carrier
public import Iterator_Protocol
public import Ordinal
public import Ordinal_Protocol
public import Ordinal_Standard_Library_Integration
public import Ordinal_Successor

extension Sequence.Difference.Changes {

    public struct Iterator: Iterator::Iterator.`Protocol` {
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

    @inlinable
    public mutating func next() -> Sequence.Difference.Change<Value>? {
        guard _index.rawValue < _count.rawValue else { return nil }
        defer { _index = _index.successor.saturating() }
        return _storage[_index]
    }
}
