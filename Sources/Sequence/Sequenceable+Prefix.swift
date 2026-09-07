public import Cardinal

extension Sequenceable where Self: ~Copyable & ~Escapable {

    @_lifetime(copy self)
    @inlinable
    public consuming func prefix(first count: Cardinal) -> Sequence.Prefix.First<Self> {
        Sequence.Prefix.First(_base: self, _count: count)
    }
}

extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {

    @_lifetime(copy self)
    @inlinable
    public consuming func prefix(
        while predicate: @escaping (Element) -> Bool
    ) -> Sequence.Prefix.While<Self> {
        Sequence.Prefix.While(_base: self, _predicate: predicate)
    }
}
