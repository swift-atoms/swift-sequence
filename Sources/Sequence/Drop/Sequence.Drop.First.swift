public import Cardinal

extension Sequence.Drop {

    public struct First<
        Base: Sequenceable<Base.Element> & ~Copyable & ~Escapable
    >: ~Copyable, ~Escapable where Base.Element: ~Copyable & ~Escapable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        let _count: Cardinal

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base, _count: Cardinal) {
            self._base = _base
            self._count = _count
        }
    }
}

extension Sequence.Drop.First: Copyable
where Base: Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {}
extension Sequence.Drop.First: Escapable
where Base: Escapable & ~Copyable, Base.Element: ~Copyable & ~Escapable {}

extension Sequence.Drop.First: Sequenceable
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {

    public typealias Element = Base.Element

    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _remaining: _count)
    }
}
