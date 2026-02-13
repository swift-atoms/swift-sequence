extension Sequence {
    /// Namespace for consuming iteration types.
    ///
    /// This namespace provides the `.consume().forEach { }` pattern for
    /// types that support consuming iteration where the container is
    /// destroyed after iteration.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let container = MyContainer([1, 2, 3])
    /// container.consume().forEach { element in
    ///     // element is owned, container is consumed
    /// }
    /// // container no longer accessible
    /// ```
    ///
    /// ## Types
    ///
    /// | Type | Description |
    /// |------|-------------|
    /// | `Protocol` | Conformance for types supporting consuming iteration |
    /// | `View` | Generic view providing iteration and cleanup |
    public enum Consume {}
}

extension Sequence.Consume {
    /// Protocol for types that support consuming iteration.
    ///
    /// Use the `.consume().forEach { }` pattern:
    ///
    /// ```swift
    /// let container = MyContainer([1, 2, 3])
    /// container.consume().forEach { element in
    ///     // element is owned, container is consumed
    /// }
    /// ```
    ///
    /// ## Consuming vs Draining
    ///
    /// | Aspect | Consume | Drain |
    /// |--------|---------|-------|
    /// | Ownership | `consuming` | `mutating` |
    /// | Container after | Destroyed | Empty, usable |
    /// | Use case | Final processing | Clear and reuse |
    ///
    /// ## Implementing
    ///
    /// Conformers return a `Sequence.Consume.View` with:
    /// - State: A `~Copyable` struct with deinit for cleanup
    /// - Next: Closure to produce next element
    ///
    /// State's deinit handles cleanup on early exit.
    ///
    /// ```swift
    /// extension MyContainer {
    ///     enum Consume {}
    /// }
    ///
    /// extension MyContainer.Consume {
    ///     struct State: ~Copyable {
    ///         var storage: Storage
    ///         var index: Int
    ///         let count: Int
    ///
    ///         deinit {
    ///             storage.deinitRemaining(from: index, count: count - index)
    ///         }
    ///     }
    /// }
    ///
    /// extension MyContainer: Swift.Sequence.Consume.Protocol {
    ///     consuming func consume() -> Sequence.Consume.View<Element, Consume.State> {
    ///         Sequence.Consume.View(
    ///             state: Consume.State(storage: storage, index: 0, count: count),
    ///             next: { state in
    ///                 guard state.index < state.count else { return nil }
    ///                 defer { state.index += 1 }
    ///                 return state.storage.moveElement(at: state.index)
    ///             }
    ///         )
    ///     }
    /// }
    /// ```
    public protocol `Protocol`: ~Copyable {
        /// The type of element produced during consuming iteration.
        associatedtype Element: ~Copyable

        /// The state type holding iteration data with deinit for cleanup.
        ///
        /// State's deinit handles cleanup of remaining elements on early exit.
        associatedtype ConsumeState

        /// Returns a consuming view for iteration.
        ///
        /// The view takes ownership of the container's elements and provides
        /// `forEach(_:)` for iteration. If iteration is interrupted early,
        /// remaining elements are cleaned up via the state's deinit.
        ///
        /// - Returns: A view that provides consuming iteration.
        /// - Complexity: O(1) to create the view.
        consuming func consume() -> View<Element, ConsumeState>
    }
}
