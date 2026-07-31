//
//  Sequence.Difference.Hunk.Side.swift
//  swift-sequence-primitives
//
//  One side of a diff hunk.
//

extension Sequence.Difference.Hunk {
    /// One side of a diff hunk: a half-open range of lines described
    /// by a 1-indexed `start` position and a `count`.
    ///
    /// Used as both `Hunk.old` (the original sequence's side) and
    /// `Hunk.new` (the modified sequence's side).
    public struct Side: Sendable, Hashable {
        /// Starting line (1-indexed).
        public let start: Ordinal
        /// Number of lines.
        public let count: Cardinal

        /// Creates a side from a 1-indexed start and a line count.
        public init(start: Ordinal, count: Cardinal) {
            self.start = start
            self.count = count
        }
    }
}
