extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var map: Property<Sequence.Map, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Map, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.Map, Self>.View(&self)
            yield &view
        }
    }
}
