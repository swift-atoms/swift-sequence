extension Sequence.`Protocol` where Self: ~Copyable {
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
