extension Sequence {
    /// Namespace for span-based access protocols.
    ///
    /// Span provides safe, bounds-checked access to contiguous memory without
    /// requiring unsafe pointer operations. These protocols define the canonical
    /// approach for accessing container elements.
    ///
    /// ## Access Patterns
    ///
    /// | Pattern | Use Case | Protocols |
    /// |---------|----------|-----------|
    /// | Property | Stable/heap storage | `Span.Protocol`, `Span.Mutable.Protocol` |
    /// | Closure | Inline/moving storage | `WithSpan.Protocol`, `WithSpan.Mutable.Protocol` |
    ///
    /// ## Choosing the Right Pattern
    ///
    /// **Property-based access** (`span` / `mutableSpan`):
    /// - Use when storage address is stable (heap-allocated)
    /// - Span lifetime tied to container borrow
    /// - More ergonomic for simple access
    ///
    /// **Closure-based access** (`withSpan` / `withMutableSpan`):
    /// - Use when storage moves with the container (inline storage)
    /// - Span lifetime strictly scoped to closure
    /// - Required for `InlineArray`-backed containers
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Property-based (heap storage)
    /// let span = container.span
    /// for i in 0..<span.count {
    ///     print(span[i])
    /// }
    ///
    /// // Closure-based (inline storage)
    /// container.withSpan { span in
    ///     for i in 0..<span.count {
    ///         print(span[i])
    ///     }
    /// }
    /// ```
    public enum Span {}
}

extension Sequence.Span {
    /// Protocol for types providing read-only span access to contiguous elements.
    ///
    /// Conforming types expose their elements via a `Span<Element>` property,
    /// providing safe, bounds-checked access without copying.
    ///
    /// ## When to Conform
    ///
    /// Conform to this protocol when your container:
    /// - Has stable storage (heap-allocated, doesn't move)
    /// - Can safely expose a span tied to `self`'s lifetime
    ///
    /// For inline storage that moves with the struct, use `Sequence.WithSpan.Protocol` instead.
    ///
    /// ## Lifetime Contract
    ///
    /// The returned span is valid only for the duration of the borrow.
    /// Implementations should use `@_lifetime(borrow self)` to enforce this:
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Span.Protocol {
    ///     var span: Span<Element> {
    ///         @_lifetime(borrow self)
    ///         borrowing get {
    ///             Span(_unsafeStart: storage.baseAddress, count: count)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let container = MyContainer([1, 2, 3])
    /// let span = container.span
    /// for i in 0..<span.count {
    ///     print(span[i])
    /// }
    /// ```
    public protocol `Protocol`: ~Copyable {
        /// The type of elements in the span.
        associatedtype Element

        /// Read-only span of the container's elements.
        ///
        /// - Important: The span is valid only for the duration of the borrow.
        ///   Do not store or return the span.
        var span: Swift.Span<Element> { get }
    }
}
