extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var count: Property<Sequence.Count, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Count, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.Count, Self>.View(&self)
            yield &view
        }
    }
}
