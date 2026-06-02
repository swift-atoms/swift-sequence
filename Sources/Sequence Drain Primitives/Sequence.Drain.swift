extension Sequence {
    /// Tag type for `.drain` property extensions and namespace for drain-related types.
    ///
    /// Use this tag with `Property.Inout` to add `.drain { }` functionality
    /// to types conforming to `Sequence.Drain.Protocol`.
    ///
    /// ## Adding drain to Your Type
    ///
    /// 1. Conform to `Sequence.Drain.Protocol`
    /// 2. Add a `drain` property returning `Property<Sequence.Drain, Self>.Inout`
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Drain.Protocol {
    ///     mutating func drain(_ body: (Element) -> Void) {
    ///         for element in storage {
    ///             body(element)
    ///         }
    ///         storage.removeAll()
    ///     }
    /// }
    ///
    /// extension MyContainer {
    ///     var drain: Property<Sequence.Drain, Self>.Inout {
    ///         mutating _read {
    ///             yield Property<Sequence.Drain, Self>.Inout(&self)
    ///         }
    ///         mutating _modify {
    ///             var accessor = Property<Sequence.Drain, Self>.Inout(&self)
    ///             yield &accessor
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.drain { }` | Drains elements via `callAsFunction`, container survives empty |
    public enum Drain {}
}
