//
//  Sequence.Difference.swift
//  swift-sequence-primitives
//
//  Namespace for sequence comparison types and algorithms.
//

extension Sequence {
    /// Namespace for sequence comparison types and algorithms.
    ///
    /// `Sequence.Difference` provides a minimal edit script between two sequences
    /// using Myers' O(ND) difference algorithm, plus unified diff formatting.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let old = ["A", "B", "C"]
    /// let new = ["A", "C", "D"]
    ///
    /// let changes = Sequence.Difference.diff(old, new)
    /// // [.both("A"), .first("B"), .both("C"), .second("D")]
    ///
    /// let diffHunks = Sequence.Difference.hunks(from: changes)
    /// ```
    public enum Difference: Sendable {}
}
