public import Iterator_Protocol

extension Sequence.Map.Compact where Base: ~Copyable & ~Escapable {

    public struct Iterator: ~Copyable, ~Escapable, Iterator::Iterator.`Protocol` {
        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _transform: (Base.Element) -> Output?

        @_lifetime(copy _base)
        @inlinable
        package init(
            _base: consuming Base.Iterator,
            _transform: @escaping (Base.Element) -> Output?
        ) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map.Compact.Iterator where Base: ~Copyable & ~Escapable {

    public typealias Element = Output

    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Output? {
        while let element = try _base.next() {
            if let transformed = _transform(element) {
                return transformed
            }
        }
        return nil
    }
}
