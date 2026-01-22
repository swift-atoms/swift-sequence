extension Sequence {
    /// Tag type for `.forEach` property extensions.
    ///
    /// Use this tag with `Property.View` to add `.forEach` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding forEach to Your Type
    ///
    /// 1. Conform to `Sequence.Protocol`
    /// 2. Add a `forEach` property returning `Property<Sequence.ForEach, Self>.View`
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Protocol {
    ///     func makeIterator() -> Array<Element>.Iterator {
    ///         storage.makeIterator()
    ///     }
    /// }
    ///
    /// extension MyContainer {
    ///     var forEach: Property<Sequence.ForEach, MyContainer>.View {
    ///         mutating _read {
    ///             yield unsafe Property<Sequence.ForEach, MyContainer>.View(&self)
    ///         }
    ///         mutating _modify {
    ///             var view = unsafe Property<Sequence.ForEach, MyContainer>.View(&self)
    ///             yield &view
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// Once you add the `forEach` property, these operations are available
    /// via `Property.View` extensions:
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.forEach { }` | Borrowing iteration via `callAsFunction` |
    /// | `.forEach.borrowing { }` | Explicit borrowing iteration |
    /// | `.forEach.consuming { }` | Consuming iteration (requires `Clearable`) |
    public enum ForEach {}
}
