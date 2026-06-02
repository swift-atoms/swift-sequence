//
//  Sequence.Difference.Steps.swift
//  swift-sequence-primitives
//
//  A Sequence.Protocol-conforming collection of edit steps.
//

extension Sequence.Difference {
    /// The result of a closure-based diff: a sequence of payload-free edit steps.
    ///
    /// `Steps` wraps `[Step]` internally but exposes only `Sequence.Protocol`,
    /// keeping stdlib `Array` hidden from the public API surface.
    ///
    /// Obtain via ``Sequence/Difference/diff(oldCount:newCount:equals:)``.
    public struct Steps: Sendable, Hashable {
        @usableFromInline
        let _storage: [Step]

        @inlinable
        package init(_ storage: [Step]) {
            self._storage = storage
        }
    }
}

// MARK: - Sequence.Protocol

extension Sequence.Difference.Steps: Sequenceable {
    /// Creates a fresh iterator that yields the stored edit steps in order.
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_storage)
    }
}

// MARK: - Counts

extension Sequence.Difference.Steps {
    /// Counts the number of removed and inserted steps.
    ///
    /// - Returns: Tuple of (removed, inserted) counts.
    @inlinable
    public func counts() -> (removed: Cardinal, inserted: Cardinal) {
        var removed: Cardinal = .zero
        var inserted: Cardinal = .zero
        for step in _storage {
            switch step {
            case .first: removed += .one
            case .second: inserted += .one
            case .both: break
            }
        }
        return (removed, inserted)
    }
}
