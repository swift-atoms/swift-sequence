extension Sequence.Consume {
    /// A consuming view that provides iterator-based iteration with automatic cleanup.
    ///
    /// This type enables the `.consume().forEach { }` pattern with proper cleanup
    /// semantics. If iteration is interrupted early (e.g., by early return or error),
    /// remaining elements are properly cleaned up via `State`'s deinit.
    ///
    /// ## Design
    ///
    /// The view holds:
    /// - `State`: A `~Copyable` data struct with deinit for cleanup
    /// - `next`: Closure to produce next element from state
    ///
    /// Cleanup is handled by `State`'s deinit, not by View. This works because
    /// when View is destroyed, State is destroyed, triggering cleanup.
    ///
    /// ## Why State's Deinit?
    ///
    /// View's deinit cannot perform cleanup because:
    /// 1. deinit cannot call `&_state` (self is immutable in deinit)
    /// 2. Cannot partially consume self in consuming func when deinit exists
    ///
    /// By putting cleanup in State's deinit, the View remains simple and the
    /// compiler can optimize the common path where all elements are consumed.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let view = container.consume()
    /// view.forEach { element in
    ///     // Process element
    /// }
    /// // If forEach completes, all elements processed
    /// // If early exit, State's deinit cleans up remaining
    /// ```
    @safe
    public struct View<Element, State: ~Copyable>: ~Copyable {
        @usableFromInline
        var _state: State

        @usableFromInline
        let _next: (inout State) -> Element?

        /// Creates a consuming view with state and iteration closure.
        ///
        /// - Parameters:
        ///   - state: The iteration state (ownership transferred).
        ///            State's deinit handles cleanup of remaining elements.
        ///   - next: Closure to produce next element, or nil when exhausted.
        @inlinable
        public init(
            state: consuming State,
            next: @escaping (inout State) -> Element?
        ) {
            self._state = state
            self._next = next
        }

        /// Returns the next element, or nil if exhausted.
        ///
        /// - Returns: The next element, or nil if all elements have been consumed.
        /// - Complexity: O(1) typically.
        @inlinable
        public mutating func next() -> Element? {
            _next(&_state)
        }

        /// Iterates over all elements, consuming the view.
        ///
        /// - Parameter body: Closure called with each element.
        /// - Complexity: O(n) where n is element count.
        @inlinable
        public consuming func forEach(_ body: (Element) -> Void) {
            while let element = _next(&_state) {
                body(element)
            }
            // State consumed here, its deinit handles any remaining cleanup
        }

        // NO deinit here - State's deinit handles cleanup
    }
}

// MARK: - Sendable

extension Sequence.Consume.View: @unchecked Sendable
where Element: Sendable, State: Sendable {}
