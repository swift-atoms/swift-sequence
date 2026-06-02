extension Sequence {
    /// Tag type for `.first` property extensions.
    ///
    /// Use this tag with `Property.Inout` to add `.first` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding first to Your Type
    ///
    /// ```swift
    /// extension MyContainer {
    ///     var first: Property<Sequence.First, MyContainer>.Inout {
    ///         mutating _read {
    ///             yield Property<Sequence.First, MyContainer>.Inout(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.first { }` | Find first element matching predicate |
    public enum First {}
}
