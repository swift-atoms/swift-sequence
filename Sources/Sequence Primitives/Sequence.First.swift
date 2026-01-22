extension Sequence {
    /// Tag type for `.first` property extensions.
    ///
    /// Use this tag with `Property.View` to add `.first` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding first to Your Type
    ///
    /// ```swift
    /// extension MyContainer {
    ///     var first: Property<Sequence.First, MyContainer>.View {
    ///         mutating _read {
    ///             yield unsafe Property<Sequence.First, MyContainer>.View(&self)
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
