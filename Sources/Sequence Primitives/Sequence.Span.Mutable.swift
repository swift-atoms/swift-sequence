extension Sequence.Span {
    /// Namespace for mutable span protocols.
    public enum Mutable {}
}

extension Sequence.Span.Mutable {
    /// Protocol for types providing mutable span access to contiguous elements.
    ///
    /// Conforming types expose their elements via a `MutableSpan<Element>` property,
    /// providing safe, bounds-checked mutable access.
    ///
    /// ## Requirements
    ///
    /// Types conforming to this protocol must also conform to `Sequence.Span.Protocol`
    /// for read-only access. The `Element` type must be `Copyable` to support
    /// copy-on-write semantics safely.
    ///
    /// ## Lifetime Contract
    ///
    /// The returned span is valid only for the duration of the exclusive borrow.
    /// Implementations should use `@_lifetime(&self)` to enforce this:
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Span.Mutable.Protocol {
    ///     var mutableSpan: MutableSpan<Element> {
    ///         @_lifetime(&self)
    ///         mutating get {
    ///             makeUnique()  // CoW if needed
    ///             return MutableSpan(_unsafeStart: storage.baseAddress, count: count)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Warning
    ///
    /// Modifying elements through mutableSpan may invalidate internal invariants
    /// (e.g., hash tables, sorted order). Only use for in-place updates that
    /// preserve element identity and any relevant ordering/hashing properties.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3])
    /// let span = container.mutableSpan
    /// span[0] = 10  // Modify in place
    /// ```
    public protocol `Protocol`: Sequence.Span.`Protocol` & ~Copyable where Element: Copyable {
        /// Mutable span of the container's elements.
        ///
        /// - Important: The span is valid only for the duration of the exclusive borrow.
        ///   Do not store or return the span.
        var mutableSpan: MutableSpan<Element> { mutating get }
    }
}
