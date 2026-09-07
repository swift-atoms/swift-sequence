public import Cardinal

extension Sequence.Prefix {

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

extension Sequence.Prefix.First: Swift.Copyable
where Base: Swift.Copyable & ~Escapable, Base.Element: ~Swift.Copyable & ~Escapable {}

extension Sequence.Prefix.First: Swift.Escapable
where Base: Swift.Escapable & ~Copyable, Base.Element: ~Copyable & ~Swift.Escapable {}

extension Sequence.Prefix.First: Sequenceable
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {

    public typealias Element = Base.Element

    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _remaining: _count)
    }
}
