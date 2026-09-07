extension Sequence.Map where Base: ~Copyable & ~Escapable, Base.Element: Copyable {

    public struct Eager<Output>: ~Copyable, ~Escapable {
        @usableFromInline
        var _base: Base

        @usableFromInline
        let _transform: (Base.Element) -> Output

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base, _transform: @escaping (Base.Element) -> Output) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map.Eager: Swift.Copyable where Base: Swift.Copyable & ~Escapable {}

extension Sequence.Map.Eager: Swift.Escapable where Base: Swift.Escapable & ~Copyable {}

extension Sequence.Map.Eager: Sequenceable where Base: ~Copyable & ~Escapable {

    public typealias Element = Output

    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _transform: _transform)
    }
}
