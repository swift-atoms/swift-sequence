extension Sequence {
    /// Tag type for `.forEach` property extensions.
    ///
    /// Use this tag with `Property.Inout` to add `.forEach` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding forEach to Your Type
    ///
    /// Conform to `Sequence.Protocol`. The `forEach` accessor property is
    /// provided automatically via protocol default.
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Protocol {
    ///     func makeIterator() -> Array<Element>.Iterator {
    ///         storage.makeIterator()
    ///     }
    /// }
    /// // MyContainer now has .forEach { }, .forEach.borrowing { },
    /// // and .forEach.consuming { } (if also Clearable).
    /// ```
    ///
    /// ## Available Operations
    ///
    /// Once you add the `forEach` property, these operations are available
    /// via `Property.Inout` extensions:
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.forEach { }` | Borrowing iteration via `callAsFunction` |
    /// | `.forEach.borrowing { }` | Explicit borrowing iteration |
    /// | `.forEach.consuming { }` | Consuming iteration (requires `Clearable`) |
    public enum ForEach {}
}
