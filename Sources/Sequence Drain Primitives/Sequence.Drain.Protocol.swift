extension Sequence.Drain {
    /// Protocol for types that support draining iteration.
    ///
    /// Draining is a mutating operation where elements are removed from
    /// the container and passed to a closure. The container survives
    /// but is empty after draining.
    ///
    /// ## Draining vs Consuming
    ///
    /// | Aspect | Drain | Consume |
    /// |--------|-------|---------|
    /// | Ownership | `mutating` | `consuming` |
    /// | Container after | Empty, usable | Destroyed |
    /// | Use case | Clear and reuse | Final processing |
    ///
    /// ## Conforming to Sequence.Drain.Protocol
    ///
    /// Implement `drain(_:)` to remove and yield elements:
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Drain.Protocol {
    ///     mutating func drain(_ body: (Element) -> Void) {
    ///         makeUnique()
    ///         for i in 0..<count {
    ///             body(storage.moveElement(at: i))
    ///         }
    ///         count = 0
    ///     }
    /// }
    /// ```
    public protocol `Protocol`: ~Copyable {
        /// The type of element produced during draining.
        associatedtype Element: ~Copyable

        /// Drains all elements, passing each to the closure.
        ///
        /// After this method returns, the container is empty but still usable.
        ///
        /// - Parameter body: A closure that receives each drained element with ownership.
        /// - Complexity: O(n) where n is the number of elements.
        mutating func drain(_ body: (consuming Element) -> Void)
    }
}
