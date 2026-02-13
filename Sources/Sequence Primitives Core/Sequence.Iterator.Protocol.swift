extension Sequence.Iterator {
    /// A protocol for iterator types, supporting `~Copyable` iterators and
    /// `~Copyable` elements.
    ///
    /// `Sequence.Iterator.Protocol` extends stdlib's `IteratorProtocol` to allow
    /// both the iterator and its elements to be `~Copyable`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// struct MyIterator: Sequence.Iterator.Protocol {
    ///     var storage: UnsafePointer<Int>
    ///     var count: Int
    ///     var position: Int = 0
    ///
    ///     mutating func next() -> Int? {
    ///         guard position < count else { return nil }
    ///         defer { position += 1 }
    ///         return storage[position]
    ///     }
    /// }
    /// ```
    ///
    /// ## ~Copyable Iterator Support
    ///
    /// Unlike stdlib's `IteratorProtocol`, this protocol allows conformers
    /// to be `~Copyable`:
    ///
    /// ```swift
    /// struct UniqueIterator: ~Copyable, Sequence.Iterator.Protocol {
    ///     var handle: FileHandle  // move-only resource
    ///
    ///     mutating func next() -> UInt8? {
    ///         handle.readByte()
    ///     }
    /// }
    /// ```
    ///
    /// ## ~Copyable Element Support
    ///
    /// The `Element` associated type suppresses the default `Copyable` constraint,
    /// enabling iteration over `~Copyable` elements via `Optional<Element>`.
    ///
    /// For containers with `~Copyable` elements, closure-based APIs provide
    /// borrowing and consuming iteration without returning owned values:
    ///
    /// | Pattern | Description |
    /// |---------|-------------|
    /// | `container.forEach { }` | Borrowing iteration via closure |
    /// | `container.drain { }` | Consuming iteration, container survives empty |
    /// | `container.consume().forEach { }` | Consuming iteration, container destroyed |
    ///
    /// ## Relationship to Swift.IteratorProtocol
    ///
    /// This protocol does not inherit from `IteratorProtocol` to avoid the
    /// `Copyable` requirement on `Self`:
    ///
    /// | Aspect | `Swift.IteratorProtocol` | `Sequence.Iterator.Protocol` |
    /// |--------|--------------------------|------------------------------|
    /// | Iterator `~Copyable` | No | Yes |
    /// | Element `~Copyable` | No | Yes |
    /// | `for-in` syntax | Yes | No |
    public protocol `Protocol`: ~Copyable {
        /// The type of element produced by the iterator.
        associatedtype Element: ~Copyable

        /// Advances to the next element and returns it, or `nil` if no next element exists.
        ///
        /// Repeatedly calling this method returns all elements of the underlying sequence
        /// in order. Once the sequence has been exhausted, all subsequent calls return `nil`.
        ///
        /// - Returns: The next element in the sequence, or `nil` if exhausted.
        mutating func next() -> Element?
    }
}

