extension Sequence.Iterator {
    /// A protocol for iterator types, supporting `~Copyable` iterators.
    ///
    /// `Sequence.Iterator.Protocol` extends stdlib's `IteratorProtocol` to allow
    /// the iterator itself to be `~Copyable`, while documenting the current
    /// language limitations around `~Copyable` elements.
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
    /// ## Element Type Constraint
    ///
    /// The `Element` associated type implicitly requires `Copyable` per
    /// [SE-0427](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0427-noncopyable-generics.md).
    /// Swift does not yet support `associatedtype Element: ~Copyable`.
    ///
    /// This limitation exists because:
    /// 1. `next() -> Element?` returns `Optional<Element>`
    /// 2. `Optional` requires its wrapped type to be `Copyable`
    ///
    /// This is a **language limitation**, not a design choice:
    /// - SE-0427 deferred `~Copyable` suppression on associated types
    /// - Standard library's `IteratorProtocol` has the same limitation
    /// - Future Swift versions may lift this restriction
    ///
    /// ## Iterating Over ~Copyable Elements
    ///
    /// For containers with `~Copyable` elements, use closure-based APIs:
    ///
    /// | Pattern | Description |
    /// |---------|-------------|
    /// | `container.forEach { }` | Borrowing iteration via closure |
    /// | `container.drain { }` | Consuming iteration, container survives empty |
    /// | `container.consume().forEach { }` | Consuming iteration, container destroyed |
    ///
    /// Example with ~Copyable elements:
    ///
    /// ```swift
    /// var array = Array<FileHandle>.Inline<8>()
    /// // ... populate with move-only handles
    ///
    /// // Borrowing iteration (handles not consumed)
    /// array.forEach { handle in
    ///     print(handle.path)
    /// }
    ///
    /// // Consuming iteration (handles moved out)
    /// array.drain { handle in
    ///     handle.close()  // takes ownership
    /// }
    /// ```
    ///
    /// ## Future Direction
    ///
    /// The "timeless" API requires two language features:
    ///
    /// | Feature | Purpose | Status |
    /// |---------|---------|--------|
    /// | `associatedtype Element: ~Copyable` | Allow noncopyable elements | Awaits future SE |
    /// | Non-optional consuming return | `next() -> Element` with end signal | Requires new pattern |
    ///
    /// Possible future patterns for ~Copyable elements:
    ///
    /// ```swift
    /// // Pattern A: Throwing instead of Optional
    /// mutating func advance() throws(EndOfSequence) -> Element
    ///
    /// // Pattern B: Closure-based (current workaround, likely permanent)
    /// mutating func withNext<R>(_ body: (inout Element) -> R) -> R?
    ///
    /// // Pattern C: Borrowing accessor (requires SE-0474)
    /// var next: Element? { yielding borrow }
    /// ```
    ///
    /// The closure-based pattern (`forEach`, `drain`) is likely the permanent
    /// solution for ~Copyable elements, as it avoids returning owned values.
    ///
    /// ## Relationship to Swift.IteratorProtocol
    ///
    /// This protocol refines `IteratorProtocol` conceptually but doesn't inherit
    /// from it to avoid the `Copyable` requirement on `Self`:
    ///
    /// | Aspect | `Swift.IteratorProtocol` | `Sequence.Iterator.Protocol` |
    /// |--------|--------------------------|------------------------------|
    /// | Iterator `~Copyable` | No | Yes |
    /// | Element `~Copyable` | No | No (language limitation) |
    /// | `for-in` syntax | Yes | No |
    public protocol `Protocol`: ~Copyable {
        /// The type of element produced by the iterator.
        ///
        /// > Note: Implicitly requires `Copyable` per SE-0427 because
        /// > `next()` returns `Element?` and `Optional` requires `Copyable`.
        /// > This is a language limitation, not a design choice.
        associatedtype Element

        /// Advances to the next element and returns it, or `nil` if no next element exists.
        ///
        /// Repeatedly calling this method returns all elements of the underlying sequence
        /// in order. Once the sequence has been exhausted, all subsequent calls return `nil`.
        ///
        /// - Returns: The next element in the sequence, or `nil` if exhausted.
        mutating func next() -> Element?
    }
}

// MARK: - Typealias for Ergonomics

extension Sequence {
    /// Alias for ``Sequence/Iterator/Protocol``.
    ///
    /// Provided for ergonomic conformance declarations:
    /// ```swift
    /// extension MyIterator: Sequence.Iterating { ... }
    /// ```
    public typealias Iterating = Sequence.Iterator.`Protocol`
}
