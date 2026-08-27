public import Cardinal

extension Sequence.Difference {

    public struct Steps: Sendable, Hashable {
        @usableFromInline
        let _storage: [Step]

        @inlinable
        package init(_ storage: [Step]) {
            self._storage = storage
        }
    }
}

extension Sequence.Difference.Steps: Sequenceable {

    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_storage)
    }
}

extension Sequence.Difference.Steps {

    @inlinable
    public func counts() -> (removed: Cardinal, inserted: Cardinal) {
        var removed = Cardinal(0)
        var inserted = Cardinal(0)
        for step in _storage {
            switch step {
            case .first: removed += Cardinal(1)
            case .second: inserted += Cardinal(1)
            case .both: break
            }
        }
        return (removed, inserted)
    }
}
