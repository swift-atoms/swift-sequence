extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var first: Property<Sequence.First, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.First, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.First, Self>.View(&self)
            yield &view
        }
    }
}
