extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var filter: Property<Sequence.Filter, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Filter, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.Filter, Self>.View(&self)
            yield &view
        }
    }
}
