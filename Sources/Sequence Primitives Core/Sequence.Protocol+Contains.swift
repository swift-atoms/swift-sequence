extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var contains: Property<Sequence.Contains, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Contains, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.Contains, Self>.View(&self)
            yield &view
        }
    }
}
