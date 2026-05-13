extension Sequence.`Protocol` where Self: ~Copyable {
    /// Fluent accessor for reduction operations: `.reduce.into(_:) { }` and `.reduce.from(_:) { }`.
    @inlinable
    public var reduce: Property<Sequence.Reduce, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Reduce, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Reduce, Self>.Inout(&self)
            yield &accessor
        }
    }
}
