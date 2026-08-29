public import Iterator_Protocol

extension Sequence.Map.Flat where Base: ~Copyable & ~Escapable {

    public struct Iterator: ~Copyable, ~Escapable {
        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _transform: (Base.Element) -> InnerSequence

        @usableFromInline
        var _inner: InnerSequence.Iterator? = nil

        @_lifetime(copy _base)
        @inlinable
        package init(
            _base: consuming Base.Iterator,
            _transform: @escaping (Base.Element) -> InnerSequence
        ) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map.Flat.Iterator:
    Iterator::Iterator.`Protocol`<InnerSequence.Element, Base.Iterator.Failure>
where
    Base: ~Copyable & ~Escapable,
    InnerSequence.Element: Escapable,
    InnerSequence.Iterator.Failure == Base.Iterator.Failure
{

    public typealias Element = InnerSequence.Element

    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Element? {
        while true {
            if _inner != nil {

                if let element = try _inner!.next() {
                    return element
                }
                _inner = nil
            }
            guard let baseElement = try _base.next() else {
                return nil
            }
            _inner = _transform(baseElement).makeIterator()
        }
    }
}
