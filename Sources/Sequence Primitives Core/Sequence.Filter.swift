extension Sequence {
    /// Tag type for `.filter` property extensions.
    ///
    /// Use this tag with `Property.View` to add `.filter` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding filter to Your Type
    ///
    /// ```swift
    /// extension MyContainer {
    ///     var filter: Property<Sequence.Filter, MyContainer>.View {
    ///         mutating _read {
    ///             yield unsafe Property<Sequence.Filter, MyContainer>.View(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.filter { }` | Filter elements, returns `[Element]` (requires `Element: Copyable`) |
    ///
    /// - Note: `filter` requires `Element: Copyable` because it returns an array
    ///   containing copies of matching elements.
    public enum Filter {}
}
