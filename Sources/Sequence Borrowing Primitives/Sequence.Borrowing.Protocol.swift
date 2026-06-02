public import Iterator_Chunk_Primitives

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
    public protocol `Protocol`<Element>: ~Copyable, ~Escapable {
        /// The type of element in the sequence.
        ///
        /// Supports move-only elements (file descriptors, unique handles)
        /// via `~Copyable`. `~Escapable` relaxation is BLOCKED until
        /// `Swift.Span<Element>` accepts `Element: ~Escapable` upstream
        /// (Swift 6.3.1 requires `Element: Escapable`).
        associatedtype Element: ~Copyable

        /// The iterator type that produces spans of elements.
        ///
        /// Suppresses both `Copyable` and `Escapable` to allow iterators
        /// that manage heap allocations (`~Copyable` for `deinit`) or
        /// borrow from the sequence (`~Escapable` for lifetime
        /// dependency). Conformers providing plain
        /// `Copyable` + `Escapable` iterators satisfy this automatically.
        associatedtype Iterator: __IteratorChunkProtocol & ~Copyable & ~Escapable
        where Iterator.Element == Element

        /// Returns a borrowing iterator over the elements.
        ///
        /// The sequence remains valid during and after iteration. The
        /// returned iterator borrows from `self` and produces spans of
        /// elements via `next(maximumCount:)`.
        ///
        /// - `@_lifetime(borrow self)`: ties the returned iterator's
        ///   lifetime to the borrow of `self`. Required because the
        ///   `Iterator` associated type permits `~Escapable` iterators;
        ///   without the annotation the compiler cannot infer the
        ///   lifetime relationship.
        /// - Returns: An iterator that produces `Span<Element>` chunks.
        @_lifetime(borrow self)
        borrowing func makeIterator() -> Iterator
    }
}
