extension Sequence {
    /// Tag type for `.drop` property extensions.
    ///
    /// Use this tag with `Property.View` to add `.drop` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding drop to Your Type
    ///
    /// ```swift
    /// extension MyContainer where Element: Copyable {
    ///     var drop: Property<Sequence.Drop, Self>.View {
    ///         mutating _read {
    ///             yield unsafe Property<Sequence.Drop, Self>.View(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.drop.first(_:)` | Skip first N elements |
    /// | `.drop.while { }` | Skip elements while predicate is true |
    public enum Drop {}
}
