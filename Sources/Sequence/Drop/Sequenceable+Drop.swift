public import Index

extension Sequenceable where Self: ~Copyable & ~Escapable {

    @_lifetime(copy self)
    @inlinable
    public consuming func drop(first count: Cardinal) -> Sequence.Drop.First<Self> {
        Sequence.Drop.First(_base: self, _count: count)
    }
}

extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {

    @_lifetime(copy self)
    @inlinable
    public consuming func drop(
        while predicate: @escaping (Element) -> Bool
    ) -> Sequence.Drop.While<Self> {
        Sequence.Drop.While(_base: self, _predicate: predicate)
    }
}
