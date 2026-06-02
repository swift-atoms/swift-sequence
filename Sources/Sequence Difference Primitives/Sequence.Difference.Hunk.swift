//
//  Sequence.Difference.Hunk.swift
//  swift-sequence-primitives
//
//  A contiguous group of changes for unified diff output.
//

extension Sequence.Difference {
    /// A contiguous group of changes with surrounding context.
    ///
    /// Hunks are the building blocks of unified diff output. Each hunk
    /// contains a contiguous region of changes plus context lines around
    /// them, matching the standard unified diff format.
    ///
    /// ## Example
    ///
    /// ```
    /// @@ -1,3 +1,3 @@
    ///  Line 1
    /// -Line 2
    /// +Line 2 (modified)
    ///  Line 3
    /// ```
    public struct Hunk: Sendable, Hashable {
        /// The original sequence's side: starting line and line count.
        public let old: Side
        /// The modified sequence's side: starting line and line count.
        public let new: Side
        /// The changes in this hunk (removals, insertions, and context).
        public let lines: [Change<String>]

        /// Creates a hunk.
        public init(
            old: Side,
            new: Side,
            lines: [Change<String>]
        ) {
            self.old = old
            self.new = new
            self.lines = lines
        }
    }
}

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

extension Sequence.Difference.Hunk {
    /// The unified-diff hunk header (e.g., `@@ -1,3 +1,4 @@`).
    public var header: String {
        "@@ -\(old.start),\(old.count) +\(new.start),\(new.count) @@"
    }
}
