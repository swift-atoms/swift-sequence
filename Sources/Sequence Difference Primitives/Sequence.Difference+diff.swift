//
//  Sequence.Difference+diff.swift
//  swift-sequence-primitives
//
//  Convenience diff for Equatable array elements.
//

extension Sequence.Difference {
    /// Computes the minimal differences between two sequences.
    ///
    /// This is a convenience wrapper around the closure-based
    /// ``diff(oldCount:newCount:equals:)`` that accepts `[Element]`
    /// arrays and returns element-annotated ``Changes``.
    ///
    /// Uses Myers' O(ND) difference algorithm (1986) which guarantees
    /// a minimal edit script — the fewest possible insertions and deletions
    /// to transform `old` into `new`.
    ///
    /// - Complexity: O(ND) time and O(ND) space, where N is the total length
    ///   of both sequences and D is the edit distance.
    ///
    /// - Parameters:
    ///   - old: The original sequence.
    ///   - new: The modified sequence.
    /// - Returns: Changes describing how to transform `old` into `new`.
    public static func diff<Element: Equatable>(
        _ old: [Element],
        _ new: [Element]
    ) -> Changes<Element> {
        let steps = diff(
            oldCount: Cardinal(UInt(old.count)),
            newCount: Cardinal(UInt(new.count)),
            equals: { old[$0] == new[$1] }
        )

        var changes: [Change<Element>] = []
        changes.reserveCapacity(steps._storage.count)

        var oldPosition: Ordinal = .zero
        var newPosition: Ordinal = .zero

        for step in steps._storage {
            switch step {
            case .first:
                changes.append(.first(old[oldPosition]))
                oldPosition = oldPosition.successor.saturating()

            case .second:
                changes.append(.second(new[newPosition]))
                newPosition = newPosition.successor.saturating()

            case .both:
                changes.append(.both(old[oldPosition]))
                oldPosition = oldPosition.successor.saturating()
                newPosition = newPosition.successor.saturating()
            }
        }

        return Changes(changes)
    }
}
