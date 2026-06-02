extension Sequenceable where Self: ~Copyable {
    /// Fluent accessor for predicate satisfaction checks: `.satisfies.all { }`, `.satisfies.any { }`, `.satisfies.none { }`.
    @inlinable
    public var satisfies: Property<Sequence.Satisfies, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Satisfies, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Satisfies, Self>.Inout(&self)
            yield &accessor
        }
    }
}
