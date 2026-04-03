extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var reduce: Property<Sequence.Reduce, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Reduce, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.Reduce, Self>.View(&self)
            yield &view
        }
    }
}
