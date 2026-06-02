public import Property_Primitives

extension Sequenceable where Self: ~Copyable {
    /// Fluent accessor for under-specified iteration hints: `.hint.count`.
    @inlinable
    public var hint: Property<Sequence.Hint, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Hint, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Hint, Self>.Inout(&self)
            yield &accessor
        }
    }
}
