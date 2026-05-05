extension Sequence {
    /// Tag type for `.count` property extensions.
    ///
    /// Use this tag with `Property.Inout` to add `.count` functionality
    /// to types conforming to `Sequence.Protocol`.
    ///
    /// ## Adding count to Your Type
    ///
    /// ```swift
    /// extension MyContainer {
    ///     var count: Property<Sequence.Count, MyContainer>.Inout {
    ///         mutating _read {
    ///             yield Property<Sequence.Count, MyContainer>.Inout(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.count.where { }` | Count elements matching predicate |
    /// | `.count.all` | Count all elements |
    public enum Count {}
}
