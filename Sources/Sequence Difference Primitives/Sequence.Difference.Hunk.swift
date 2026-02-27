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
        /// Starting line in the original sequence (1-indexed).
        public let oldStart: Ordinal
        /// Number of lines from the original sequence.
        public let oldCount: Cardinal
        /// Starting line in the modified sequence (1-indexed).
        public let newStart: Ordinal
        /// Number of lines in the modified sequence.
        public let newCount: Cardinal
        /// The changes in this hunk (removals, insertions, and context).
        public let lines: [Change<String>]

        /// Creates a hunk.
        public init(
            oldStart: Ordinal,
            oldCount: Cardinal,
            newStart: Ordinal,
            newCount: Cardinal,
            lines: [Change<String>]
        ) {
            self.oldStart = oldStart
            self.oldCount = oldCount
            self.newStart = newStart
            self.newCount = newCount
            self.lines = lines
        }

        /// The patch mark header (e.g., `@@ -1,3 +1,4 @@`).
        public var patchMark: String {
            "@@ -\(oldStart),\(oldCount) +\(newStart),\(newCount) @@"
        }
    }
}
