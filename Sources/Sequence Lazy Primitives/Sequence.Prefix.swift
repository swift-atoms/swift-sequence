extension Sequence {
    /// Tag type for `.prefix` property extensions.
    ///
    /// Use this tag with `Property.Inout` to add `.prefix` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding prefix to Your Type
    ///
    /// ```swift
    /// extension MyContainer where Element: Copyable {
    ///     var prefix: Property<Sequence.Prefix, Self>.Inout {
    ///         mutating _read {
    ///             yield Property<Sequence.Prefix, Self>.Inout(&self)
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
