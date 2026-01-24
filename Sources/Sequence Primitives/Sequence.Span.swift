extension Sequence {
    /// Tag type for `.span` property extensions.
    ///
    /// Use this tag with `Property.View` to add span-based iteration
    /// to types conforming to `Sequence.Borrowing.Protocol`.
    ///
    /// ## Adding span to Your Type
    ///
    /// 1. Conform to `Sequence.Borrowing.Protocol`
    /// 2. Add a `span` property returning `Property<Sequence.Span, Self>.View`
    ///
    /// ```swift
    /// extension MyContainer: Sequence.Borrowing.`Protocol` {
    ///     @_lifetime(borrow self)
    ///     borrowing func makeIterator() -> Span.Batch.Iterator<Element> {
    ///         Span.Batch.Iterator(span: storage.span)
    ///     }
    /// }
    ///
    /// extension MyContainer {
    ///     var span: Property<Sequence.Span, MyContainer>.View {
    ///         mutating _read {
    ///             yield unsafe Property<Sequence.Span, MyContainer>.View(&self)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description |
    /// |-----------|-------------|
    /// | `.span.forEach { }` | Process each span batch |
    /// | `.span.elements { }` | Process each element from spans |
    /// | `.span.reduceInto(_:) { }` | Reduce over spans with mutable accumulator |
    /// | `.span.reduceFrom(_:) { }` | Reduce over spans with immutable accumulator |
    public enum Span {}
}
