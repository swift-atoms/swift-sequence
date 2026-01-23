extension Sequence.WithSpan {
    /// Namespace for mutable closure-scoped span protocols.
    public enum Mutable {}
}

extension Sequence.WithSpan.Mutable {
    /// Protocol for types providing closure-scoped mutable span access.
    ///
    /// The closure receives a mutable span that is valid only for the closure's duration.
    /// This pattern ensures the span cannot escape, making it safe for inline storage.
    ///
    /// ## Requirements
    ///
    /// Types conforming to this protocol must also conform to `Sequence.WithSpan.Protocol`
    /// for read-only access.
    ///
    /// ## Implementation
    ///
    /// ```swift
    /// extension MyInlineContainer: Sequence.WithSpan.Mutable.Protocol {
    ///     mutating func withMutableSpan<R, E: Swift.Error>(
    ///         _ body: (borrowing MutableSpan<Element>) throws(E) -> R
    ///     ) throws(E) -> R {
    ///         try withUnsafeMutablePointer(to: &storage) { ptr throws(E) in
    ///             let span = MutableSpan(_unsafeStart: ptr, count: count)
    ///             return try body(span)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Warning
    ///
    /// Modifying elements through the span may invalidate internal invariants
    /// (e.g., hash tables, sorted order). Only use for in-place updates that
    /// preserve element identity and any relevant ordering/hashing properties.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// container.withMutableSpan { span in
    ///     for i in 0..<span.count {
    ///         span[i] *= 2  // Double each element
    ///     }
    /// }
    /// ```
    public protocol `Protocol`: Sequence.WithSpan.`Protocol` & ~Copyable {
        /// Provides closure-scoped access to a mutable span.
        ///
        /// - Parameter body: A closure that receives the mutable span.
        /// - Returns: The result of the closure.
        /// - Throws: Rethrows any error from the closure.
        mutating func withMutableSpan<R, E: Swift.Error>(
            _ body: (borrowing MutableSpan<Element>) throws(E) -> R
        ) throws(E) -> R
    }
}
