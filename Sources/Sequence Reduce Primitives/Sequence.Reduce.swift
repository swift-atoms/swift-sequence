extension Sequence {
    /// Tag type for `.reduce` property extensions.
    ///
    /// Use this tag with `Property.Inout` to add `.reduce` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding reduce to Your Type
    ///
    /// ```swift
    /// extension MyContainer {
    ///     var reduce: Property<Sequence.Reduce, MyContainer>.Inout {
    ///         mutating _read {
    ///             yield Property<Sequence.Reduce, MyContainer>.Inout(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.reduce.into(_:) { }` | Reduce with mutable accumulator |
    /// | `.reduce.from(_:) { }` | Reduce with immutable accumulator |
    public enum Reduce {}
}
