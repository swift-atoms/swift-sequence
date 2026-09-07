extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {

    @_lifetime(copy self)
    @inlinable
    public consuming func map<Output>(
        _ transform: @escaping (Element) -> Output
    ) -> Sequence.Map<Self>.Eager<Output> {
        Sequence.Map<Self>.eager(consume self, transform)
    }
}

extension Sequenceable where Self: Copyable {

    @inlinable
    public var map: Sequence.Map<Self> {
        consuming get { Sequence.Map(_base: self) }
    }
}
