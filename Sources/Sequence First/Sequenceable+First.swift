public import Property_Inout

extension Sequenceable where Self: ~Copyable {

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
