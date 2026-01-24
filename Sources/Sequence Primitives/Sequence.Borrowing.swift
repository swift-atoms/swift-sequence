extension Sequence {
    /// Namespace for borrowing sequence types.
    ///
    /// ## Overview
    ///
    /// `Sequence.Borrowing` provides protocols and types for span-based
    /// borrowing iteration. Unlike element-at-a-time iteration, borrowing
    /// sequences return `Span<Element>` chunks, enabling efficient bulk access.
    ///
    /// ## Protocol Hierarchy
    ///
    /// ```
    /// Sequence.Protocol                    ← element-at-a-time, owns iterator
    ///       ↓
    /// Sequence.Borrowing.Protocol          ← span-at-a-time, borrows from container
    /// ```
    ///
    /// ## When to Use
    ///
    /// Use borrowing sequences when:
    /// - Iterating over contiguous memory
    /// - Processing elements in batches
    /// - Avoiding per-element function call overhead
    ///
    /// ## SE-0427 Limitation
    ///
    /// The `Element` type implicitly requires `Copyable` because Swift does not
    /// support `associatedtype Element: ~Copyable`. This matches the pitch's
    /// acknowledged limitation and is forward-compatible.
    public enum Borrowing {}
}
