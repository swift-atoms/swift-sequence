public import Cardinal
public import Iterator

extension Sequence.Drop.While where Base: ~Copyable & ~Escapable {

    public struct Iterator: ~Copyable, ~Escapable,
        Iterating<Base.Element, Base.Iterator.Failure>
    {
        @_implements(Iterating,Element)
        public typealias ScalarElement = Base.Element

        @_implements(Iterating,Failure)
        public typealias ScalarFailure = Base.Iterator.Failure

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @usableFromInline
        var _dropping: Bool

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
            self._dropping = true
        }
    }
}

extension Sequence.Drop.While.Iterator where Base: ~Copyable & ~Escapable {

    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        while let element = try _base.next() {
            if _dropping && _predicate(element) {
                continue
            }
            _dropping = false
            return element
        }
        return nil
    }
}

extension Sequence.Drop.While.Iterator:
    __IteratorChunkProtocol<Base.Element, Base.Iterator.Failure>
where
    Base: ~Copyable & ~Escapable,
    Base.Element: Escapable,
    Base.Iterator: __IteratorChunkProtocol<
        Base.Element, Base.Iterator.Failure
    >
{
    @_implements(__IteratorChunkProtocol,Element)
    public typealias ChunkElement = Base.Element

    @_implements(__IteratorChunkProtocol,Failure)
    public typealias ChunkFailure = Base.Iterator.Failure

    @_lifetime(&self)
    @inlinable
    public mutating func next(
        maximumCount: Cardinal
    ) throws(Base.Iterator.Failure) -> Swift.Span<Base.Element> {
        if !_dropping {
            return try _base.next(maximumCount: maximumCount)
        }
        while _dropping {
            let span = try _base.next(
                maximumCount: maximumCount > Cardinal(0) ? maximumCount : .max
            )
            if span.isEmpty { return span }
            for i in span.indices {
                if !_predicate(span[i]) {
                    _dropping = false
                    return span.extracting(droppingFirst: i)
                }
            }
        }
        return try _base.next(maximumCount: Cardinal(0))
    }
}
