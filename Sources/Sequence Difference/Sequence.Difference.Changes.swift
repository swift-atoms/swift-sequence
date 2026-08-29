public import Cardinal
public import Cardinal_Carrier
public import Sequence_Protocol

extension Sequence.Difference {

    public struct Changes<Value> {
        @usableFromInline
        let _storage: [Change<Value>]

        @inlinable
        package init(_ storage: [Change<Value>]) {
            self._storage = storage
        }
    }
}

extension Sequence.Difference.Changes: Sequenceable {

    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_storage)
    }
}

extension Sequence.Difference.Changes: Sendable where Value: Sendable {}

extension Sequence.Difference.Changes {

    @inlinable
    public func counts() -> (removed: Cardinal, inserted: Cardinal) {
        var removed: Cardinal = .zero
        var inserted: Cardinal = .zero
        for change in _storage {
            switch change {
            case .first: removed += .one
            case .second: inserted += .one
            case .both: break
            }
        }
        return (removed, inserted)
    }
}
