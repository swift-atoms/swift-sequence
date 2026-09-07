extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {

    @_lifetime(copy self)
    @inlinable
    public consuming func filter(
        _ predicate: @escaping (Element) -> Bool
    ) -> Sequence.Filter<Self> {
        Sequence.Filter(_base: self, _predicate: predicate)
    }
}
