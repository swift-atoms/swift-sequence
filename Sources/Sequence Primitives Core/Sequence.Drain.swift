extension Sequence {
    /// Tag type for `.drain` property extensions and namespace for drain-related types.
    ///
    /// Use this tag with `Property.View` to add `.drain { }` functionality
    /// to types conforming to `Sequence.Drain.Protocol`.
    ///
    /// ## Adding drain to Your Type
    ///
    /// 1. Conform to `Sequence.Drain.Protocol`
    /// 2. Add a `drain` property returning `Property<Sequence.Drain, Self>.View`
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Drain.Protocol {
    ///     mutating func drain(_ body: (Element) -> Void) {
    ///         for element in storage {
    ///             body(element)
    ///         }
    ///         storage.removeAll()
    ///     }
    /// }
    ///
    /// extension MyContainer {
    ///     var drain: Property<Sequence.Drain, Self>.View {
    ///         mutating _read {
    ///             yield unsafe Property<Sequence.Drain, Self>.View(&self)
    ///         }
    ///         mutating _modify {
    ///             var view = unsafe Property<Sequence.Drain, Self>.View(&self)
    ///             yield &view
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.drain { }` | Drains elements via `callAsFunction`, container survives empty |
    public enum Drain {}
}

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
