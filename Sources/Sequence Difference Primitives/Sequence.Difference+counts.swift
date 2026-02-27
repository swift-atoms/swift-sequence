//
//  Sequence.Difference+counts.swift
//  swift-sequence-primitives
//
//  Change counting for diff output.
//

extension Sequence.Difference {
    /// Counts the number of removed and inserted elements.
    ///
    /// - Parameter changes: The computed differences.
    /// - Returns: Tuple of (removed, inserted) counts.
    public static func counts<Element>(
        of changes: [Change<Element>]
    ) -> (removed: Int, inserted: Int) {
        var removed = 0
        var inserted = 0
        for change in changes {
            switch change {
            case .first: removed += 1
            case .second: inserted += 1
            case .both: break
            }
        }
        return (removed, inserted)
    }
}
