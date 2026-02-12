extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var prefix: Property<Sequence.Prefix, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Prefix, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.Prefix, Self>.View(&self)
            yield &view
        }
    }
}
