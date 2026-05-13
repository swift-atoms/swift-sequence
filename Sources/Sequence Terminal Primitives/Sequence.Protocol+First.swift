extension Sequence.`Protocol` where Self: ~Copyable {
    /// Fluent accessor for finding the first matching element: `.first { predicate }`.
    @inlinable
    public var first: Property<Sequence.First, Self>.Inout {
        mutating _read {
            yield Property<Sequence.First, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.First, Self>.Inout(&self)
            yield &accessor
        }
    }
}
