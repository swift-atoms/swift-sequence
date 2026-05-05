extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var contains: Property<Sequence.Contains, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Contains, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Contains, Self>.Inout(&self)
            yield &accessor
        }
    }
}
