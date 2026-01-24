extension Sequence.Iterator {
    /// Namespace for borrowing iterator types.
    ///
    /// ## Overview
    ///
    /// `Sequence.Iterator.Borrowing` provides protocols for iterators that
    /// return spans rather than individual elements. These iterators borrow
    /// from their underlying sequence.
    ///
    /// ## Protocol Hierarchy
    ///
    /// ```
    /// Sequence.Iterator.Protocol           ← next() -> Element?
    ///       ↓
    /// Sequence.Iterator.Borrowing.Protocol ← nextSpan(maximumCount:) -> Span<Element>
    /// ```
    ///
    /// ## Lifetime Semantics
    ///
    /// Borrowing iterators are `~Escapable` because the spans they return
    /// borrow from the iterator (which borrows from the sequence). This
    /// prevents dangling references.
    public enum Borrowing {}
}
