extension Sequenceable where Self: ~Copyable {

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
