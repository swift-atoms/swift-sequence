extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var satisfies: Property<Sequence.Satisfies, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Satisfies, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.Satisfies, Self>.View(&self)
            yield &view
        }
    }
}
