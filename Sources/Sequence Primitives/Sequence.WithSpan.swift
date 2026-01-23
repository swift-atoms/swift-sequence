extension Sequence {
    /// Namespace for closure-scoped span access protocols.
    ///
    /// Some containers (e.g., those with inline storage) cannot safely expose
    /// span properties because the storage address moves with the struct.
    /// These protocols provide closure-based access where the span lifetime
    /// is strictly scoped.
    ///
    /// ## When to Use
    ///
    /// Use closure-scoped access when:
    /// - Storage is inline (`InlineArray`-backed)
    /// - Container might relocate during access
    /// - Lifetime cannot be expressed via property accessors
    ///
    /// For heap-backed storage with stable addresses, prefer `Sequence.Span.Protocol`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// container.withSpan { span in
    ///     for i in 0..<span.count {
    ///         print(span[i])
    ///     }
    /// }
    /// ```
    ///
    /// ## Typed Throws
    ///
    /// These protocols support typed throws for precise error handling:
    ///
    /// ```swift
    /// try container.withSpan { span throws(MyError) in
    ///     guard span.count > 0 else { throw .empty }
    ///     return span[0]
    /// }
    /// ```
    public enum WithSpan {}
}

extension Sequence.WithSpan {
    /// Protocol for types providing closure-scoped read-only span access.
    ///
    /// The closure receives a span that is valid only for the closure's duration.
    /// This pattern ensures the span cannot escape, making it safe for inline storage.
    ///
    /// ## When to Conform
    ///
    /// Conform to this protocol when your container:
    /// - Has inline storage that moves with the struct
    /// - Cannot safely expose a span property
    /// - Needs scoped lifetime guarantees
    ///
    /// ## Implementation
    ///
    /// ```swift
    /// extension MyInlineContainer: Sequence.WithSpan.Protocol {
    ///     func withSpan<R, E: Swift.Error>(
    ///         _ body: (Span<Element>) throws(E) -> R
    ///     ) throws(E) -> R {
    ///         try withUnsafePointer(to: storage) { ptr throws(E) in
    ///             let span = Span(_unsafeStart: ptr, count: count)
    ///             return try body(span)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let sum = container.withSpan { span in
    ///     var total = 0
    ///     for i in 0..<span.count {
    ///         total += span[i]
    ///     }
    ///     return total
    /// }
    /// ```
    public protocol `Protocol`: ~Copyable {
        /// The type of elements in the span.
        associatedtype Element

        /// Provides closure-scoped access to a read-only span.
        ///
        /// - Parameter body: A closure that receives the span.
        /// - Returns: The result of the closure.
        /// - Throws: Rethrows any error from the closure.
        func withSpan<R, E: Swift.Error>(
            _ body: (Swift.Span<Element>) throws(E) -> R
        ) throws(E) -> R
    }
}
