extension Sequence {
    /// Tag type for `.prefix` property extensions.
    ///
    /// Use this tag with `Property.View` to add `.prefix` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding prefix to Your Type
    ///
    /// ```swift
    /// extension MyContainer where Element: Copyable {
    ///     var prefix: Property<Sequence.Prefix, Self>.View {
    ///         mutating _read {
    ///             yield unsafe Property<Sequence.Prefix, Self>.View(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.prefix.first(_:)` | Take first N elements |
    /// | `.prefix.while { }` | Take elements while predicate is true |
    public enum Prefix {}
}
