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
            oldCount: try! Cardinal(old.count),
            newCount: try! Cardinal(new.count),
            equals: { old[Int(bitPattern: $0)] == new[Int(bitPattern: $1)] }
        )

        var changes: [Change<Element>] = []
        changes.reserveCapacity(steps._storage.count)

        var oldIndex = 0
        var newIndex = 0

        for step in steps._storage {
            switch step {
            case .first:
                changes.append(.first(old[oldIndex]))
                oldIndex += 1
            case .second:
                changes.append(.second(new[newIndex]))
                newIndex += 1
            case .both:
                changes.append(.both(old[oldIndex]))
                oldIndex += 1
                newIndex += 1
            }
        }

        return Changes(changes)
    }
}
