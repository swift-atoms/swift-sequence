extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var drop: Property<Sequence.Drop, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Drop, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.Drop, Self>.View(&self)
            yield &view
        }
    }
}
