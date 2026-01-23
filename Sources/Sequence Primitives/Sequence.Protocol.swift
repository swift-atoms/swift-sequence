extension Sequence {
    /// A protocol for types that can be iterated, supporting `~Copyable`.
    ///
    /// `Sequence.Protocol` mirrors stdlib's `Sequence` but allows `~Copyable` conformers.
    /// This enables iteration over move-only containers.
    ///
    /// ## Conforming to Sequence.Protocol
    ///
    /// Implement `makeIterator()` to return an iterator over your elements:
    ///
    /// ```swift
    /// struct MyContainer<Element>: ~Copyable {
    ///     var storage: [Element]
    /// }
    ///
    /// extension MyContainer: Swift.Sequence.Protocol {
    ///     func makeIterator() -> Array<Element>.Iterator {
    ///         storage.makeIterator()
    ///     }
    /// }
    /// ```
    ///
    /// ## Difference from stdlib Sequence
    ///
    /// | Aspect | stdlib `Sequence` | `Sequence.Protocol` |
    /// |--------|-------------------|---------------------|
    /// | `~Copyable` support | No | Yes |
    /// | `for-in` syntax | Yes | No (use `.forEach`) |
    /// | Iterator requirement | `IteratorProtocol` | `IteratorProtocol` |
    ///
    /// ## ForEach Integration
    ///
    /// Types conforming to `Sequence.Protocol` can add a `.forEach` property
    /// to get borrowing and consuming iteration via `Property.View` extensions.
    /// See `Sequence.ForEach` for details.
    public protocol `Protocol`: ~Copyable {
        /// The type of element produced by the sequence.
        associatedtype Element

        /// The iterator type that produces elements.
        associatedtype Iterator: IteratorProtocol where Iterator.Element == Element

        /// Returns an iterator over the elements of this sequence.
        ///
        /// - Returns: An iterator that produces elements of type `Element`.
        borrowing func makeIterator() -> Iterator
    }
}
