extension Sequence {
    /// Tag type for `.satisfies` property extensions.
    ///
    /// Use this tag with `Property.Inout` to add `.satisfies` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding satisfies to Your Type
    ///
    /// ```swift
    /// extension MyContainer {
    ///     var satisfies: Property<Sequence.Satisfies, MyContainer>.Inout {
    ///         mutating _read {
    ///             yield Property<Sequence.Satisfies, MyContainer>.Inout(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.satisfies.all { }` | Check if all elements satisfy predicate |
    /// | `.satisfies.any { }` | Check if any element satisfies predicate |
    /// | `.satisfies.none { }` | Check if no elements satisfy predicate |
    public enum Satisfies {}
}
