extension Sequence {
    /// Tag type for `.span` property extensions.
    ///
    /// Use this tag with `Property.Inout` to add span-based iteration
    /// to types conforming to `Sequence.Borrowing.Protocol`.
    ///
    /// ## Adding span to Your Type
    ///
    /// 1. Conform to `Sequence.Borrowing.Protocol`
    /// 2. Add a `span` property returning `Property<Sequence.Span, Self>.Inout`
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
    ///     var span: Property<Sequence.Span, MyContainer>.Inout {
    ///         mutating _read {
    ///             yield Property<Sequence.Span, MyContainer>.Inout(&self)
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
    /// | `.span.reduce(into:) { }` | Reduce over spans with mutable accumulator |
    /// | `.span.reduce(from:) { }` | Reduce over spans with immutable accumulator |
    public enum Span {}
}
