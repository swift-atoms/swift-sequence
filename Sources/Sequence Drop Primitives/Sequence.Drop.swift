extension Sequence {
    /// Tag type for `.drop` property extensions.
    ///
    /// Use this tag with `Property.Inout` to add `.drop` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding drop to Your Type
    ///
    /// ```swift
    /// extension MyContainer where Element: Copyable {
    ///     var drop: Property<Sequence.Drop, Self>.Inout {
    ///         mutating _read {
    ///             yield Property<Sequence.Drop, Self>.Inout(&self)
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
