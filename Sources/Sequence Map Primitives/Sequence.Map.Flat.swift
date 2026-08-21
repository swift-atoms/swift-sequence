extension Sequence.Map where Base: ~Copyable & ~Escapable, Base.Element: Copyable {

    public struct Flat<
        InnerSequence: Sequenceable<InnerSequence.Element>
    >: ~Copyable, ~Escapable
    where InnerSequence.Element: Copyable & Escapable, InnerSequence.Iterator: Escapable {
        @usableFromInline
        var _base: Base

        @usableFromInline
        let _transform: (Base.Element) -> InnerSequence

        @_lifetime(copy _base)
        @inlinable
        package init(
            _base: consuming Base,
            _transform: @escaping (Base.Element) -> InnerSequence
        ) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map.Flat: Copyable
where Base: Copyable & ~Escapable, InnerSequence.Element: Escapable {}
extension Sequence.Map.Flat: Escapable
where Base: Escapable & ~Copyable, InnerSequence.Element: Escapable {}

extension Sequence.Map.Flat: Sequenceable
where
    Base: ~Copyable & ~Escapable,
    InnerSequence.Element: Escapable,
    InnerSequence.Iterator.Failure == Base.Iterator.Failure
{

    public typealias Element = InnerSequence.Element

    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _transform: _transform)
    }
}
