extension Sequence {
    /// Protocol for sequences that can be cleared, supporting `~Copyable`.
    ///
    /// `Sequence.Clearable` extends `Sequence.Protocol` with the ability
    /// to remove all elements. This enables consuming iteration via
    /// `.forEach.consuming { }`.
    ///
    /// ## Conforming to Sequence.Clearable
    ///
    /// Implement `removeAll()` to clear all elements:
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Clearable {
    ///     mutating func removeAll() {
    ///         storage.removeAll()
    ///     }
    /// }
    /// ```
    ///
    /// ## Consuming Iteration
    ///
    /// Types conforming to `Sequence.Clearable` get `.forEach.consuming { }`
    /// automatically via the `Property.View` extension:
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3])
    /// container.forEach.consuming { element in
    ///     print(element)
    /// }
    /// // container is now empty
    /// ```
    public protocol Clearable: Sequence.`Protocol` & ~Copyable {
        /// Removes all elements from the sequence.
        mutating func removeAll()
    }
}
