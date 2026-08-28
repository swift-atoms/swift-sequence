public import Iterator_Protocol

extension Sequence.Filter where Base: ~Copyable & ~Escapable {

    public struct Iterator: ~Copyable, ~Escapable,
        Iterator.Iterator.`Protocol`<Base.Element, Base.Iterator.Failure>
    {
        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
        }
    }
}

extension Sequence.Filter.Iterator where Base: ~Copyable & ~Escapable {

    public typealias Element = Base.Element

    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        while let element = try _base.next() {
            if _predicate(element) {
                return element
            }
        }
        return nil
    }
}
