extension Sequence {
    /// Tag type for `.contains` property extensions.
    ///
    /// Use this tag with `Property.Inout` to add `.contains` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding contains to Your Type
    ///
    /// ```swift
    /// extension MyContainer {
    ///     var contains: Property<Sequence.Contains, MyContainer>.Inout {
    ///         mutating _read {
    ///             yield Property<Sequence.Contains, MyContainer>.Inout(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.contains { }` | Check if sequence contains element matching predicate |
    public enum Contains {}
}
