extension Sequence.`Protocol` where Self: ~Copyable {
    /// Fluent accessor for counting operations: `.count.all` and `.count.where { predicate }`.
    @inlinable
    public var count: Property<Sequence.Count, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Count, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Count, Self>.Inout(&self)
            yield &accessor
        }
    }
}
