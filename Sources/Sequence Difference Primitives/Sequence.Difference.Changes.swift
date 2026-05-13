//
//  Sequence.Difference.Changes.swift
//  swift-sequence-primitives
//
//  A Sequence.Protocol-conforming collection of element-annotated changes.
//

extension Sequence.Difference {
    /// The result of diffing two `Equatable` sequences: a sequence of element-carrying changes.
    ///
    /// `Changes` wraps `[Change<Value>]` internally but exposes only `Sequence.Protocol`,
    /// keeping stdlib `Array` hidden from the public API surface.
    ///
    /// Obtain via ``Sequence/Difference/diff(_:_:)``.
    public struct Changes<Value> {
        @usableFromInline
        let _storage: [Change<Value>]

        @inlinable
        init(_ storage: [Change<Value>]) {
            self._storage = storage
        }
    }
}

// MARK: - Sequence.Protocol

extension Sequence.Difference.Changes: Sequence.`Protocol` {
    /// Creates a fresh iterator that yields the stored element-carrying changes in order.
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_storage)
    }
}

// MARK: - Sendable

extension Sequence.Difference.Changes: Sendable where Value: Sendable {}

// MARK: - Counts

extension Sequence.Difference.Changes {
    /// Counts the number of removed and inserted changes.
    ///
    /// - Returns: Tuple of (removed, inserted) counts.
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
