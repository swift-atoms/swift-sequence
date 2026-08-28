public import Property_Inout

extension Sequenceable where Self: ~Copyable {

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
