extension Sequence.Borrowing {
    /// A protocol for sequences that support borrowing span-based iteration.
    ///
    /// `Sequence.Borrowing.Protocol` enables efficient iteration by returning
    /// `Span<Element>` chunks rather than individual elements. This reduces
    /// function call overhead and enables bulk operations.
    ///
    /// ## Conforming to Sequence.Borrowing.Protocol
    ///
    /// Implement `makeIterator()` to return a borrowing iterator:
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Borrowing.`Protocol` {
    ///     @_lifetime(borrow self)
    ///     borrowing func makeIterator() -> Span.Batch.Iterator<Element> {
    ///         Span.Batch.Iterator(span: storage.span)
    ///     }
    /// }
    /// ```
    ///
    /// ## Iterator Requirements
    ///
    /// The iterator must conform to `Sequence.Iterator.Borrowing.Protocol`,
    /// which provides `nextSpan(maximumCount:)` for batch access.
    ///
    /// ## Difference from Sequence.Protocol
    ///
    /// | Aspect | `Sequence.Protocol` | `Sequence.Borrowing.Protocol` |
    /// |--------|---------------------|-------------------------------|
    /// | Return type | `Element?` | `Span<Element>` |
    /// | Granularity | Single element | Batch of elements |
    /// | Lifetime | Iterator owns elements | Iterator borrows from sequence |
    ///
    public protocol `Protocol`: ~Copyable, ~Escapable {
        /// The type of element in the sequence.
        associatedtype Element: ~Copyable

        /// The iterator type that produces spans of elements.
        associatedtype Iterator: Sequence.Iterator.Borrowing.`Protocol`
            where Iterator.Element == Element

        /// Returns a borrowing iterator over the elements.
        ///
        /// The returned iterator borrows from this sequence and produces
        /// spans of elements via `nextSpan(maximumCount:)`.
        ///
        /// - Returns: An iterator that produces `Span<Element>` chunks.
        @_lifetime(borrow self)
        borrowing func makeIterator() -> Iterator
    }
}
