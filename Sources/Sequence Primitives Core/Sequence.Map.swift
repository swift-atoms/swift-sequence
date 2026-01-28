extension Sequence {
    /// Tag type for `.map` property extensions.
    ///
    /// Use this tag with `Property.View` to add `.map` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding map to Your Type
    ///
    /// ```swift
    /// extension MyContainer {
    ///     var map: Property<Sequence.Map, MyContainer>.View {
    ///         mutating _read {
    ///             yield unsafe Property<Sequence.Map, MyContainer>.View(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.map { }` | Transform elements, returns `[U]` |
    public enum Map {}
}
