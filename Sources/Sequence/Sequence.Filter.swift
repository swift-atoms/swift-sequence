extension Sequence {

    public struct Filter<
        Base: Sequenceable<Base.Element> & ~Copyable & ~Escapable
    >: ~Copyable, ~Escapable where Base.Element: Copyable & Escapable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
        }
    }
}

extension Sequence.Filter: Copyable
where Base: Copyable & ~Escapable, Base.Element: Escapable {}
extension Sequence.Filter: Escapable
where Base: Escapable & ~Copyable, Base.Element: Escapable {}

extension Sequence.Filter: Sequenceable
where Base: ~Copyable & ~Escapable, Base.Element: Escapable {

    public typealias Element = Base.Element

    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _predicate: _predicate)
    }
}
