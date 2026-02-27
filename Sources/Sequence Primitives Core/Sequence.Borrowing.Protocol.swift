extension Sequence.Borrowing {
    /// A protocol for sequences that support non-destructive borrowing
    /// iteration.
    ///
    /// `Sequence.Borrowing.Protocol` provides span-based iteration where
    /// the iterator borrows from the sequence. The sequence remains valid
    /// during and after iteration.
    ///
    /// ## Distinction from `Sequence.Protocol`
    ///
    /// | Aspect | `Sequence.Protocol` | `Sequence.Borrowing.Protocol` |
    /// |--------|---------------------|-------------------------------|
    /// | `makeIterator()` | `consuming` | `borrowing` |
    /// | Lifetime annotation | `@_lifetime(copy self)` | `@_lifetime(borrow self)` |
    /// | Purpose | Lazy pipelines, terminal ops | Non-destructive span access |
    /// | Dual conformance | — | Types can conform to both |
    ///
    /// `Sequence.Protocol` consumes (for lazy pipelines).
    /// `Sequence.Borrowing.Protocol` borrows (for in-place span access).
    ///
    /// ## Conforming to Sequence.Borrowing.Protocol
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
    /// ### `@_lifetime(borrow self)`
    ///
    /// The returned iterator's lifetime is tied to the borrow of `self`.
    /// The iterator cannot outlive the sequence it borrows from.
    ///
    /// ### Use Case
    ///
    /// Contiguous storage types that can lend their memory as spans
    /// without copying. The iterator walks the storage by yielding spans
    /// that borrow from it.
    ///
    /// > Note: The `Iterator` associated type does not include
    /// > `& ~Copyable & ~Escapable` (unlike `Sequence.Protocol`'s
    /// > associated type). This may need updating for consistency —
    /// > flagged for review.
    public protocol `Protocol`: ~Copyable, ~Escapable {
        /// The type of element in the sequence.
        associatedtype Element: ~Copyable

        /// The iterator type that produces spans of elements.
        ///
        /// > Note: Does not suppress `Copyable` or `Escapable` (unlike
        /// > `Sequence.Protocol`'s `Iterator` associated type). This may
        /// > need updating for consistency.
        associatedtype Iterator: Sequence.Iterator.`Protocol`
            where Iterator.Element == Element

        /// Returns a borrowing iterator over the elements.
        ///
        /// The sequence remains valid during and after iteration. The
        /// returned iterator borrows from `self` and produces spans of
        /// elements via `nextSpan(maximumCount:)`.
        ///
        /// - `@_lifetime(borrow self)`: The iterator's lifetime is tied
        ///   to the borrow of `self`.
        /// - Returns: An iterator that produces `Span<Element>` chunks.
        @_lifetime(borrow self)
        borrowing func makeIterator() -> Iterator
    }
}
