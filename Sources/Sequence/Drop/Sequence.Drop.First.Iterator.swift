public import Cardinal
public import Iterator

extension Sequence.Drop.First
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {

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
        var _remaining: Cardinal

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _remaining: Cardinal) {
            self._base = _base
            self._remaining = _remaining
        }
    }
}

extension Sequence.Drop.First.Iterator
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {

    @_lifetime(&self)
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        while _remaining > Cardinal(0) {
            _remaining = Cardinal(_remaining.rawValue - 1)
            switch try _base.next() {
            case .none: return nil
            case .some: continue
            }
        }
        return try _base.next()
    }
}

extension Sequence.Drop.First.Iterator:
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
        while _remaining > Cardinal(0) {
            let span = try _base.next(maximumCount: _remaining)
            if span.isEmpty {
                return span
            }
            let consumed = UInt(span.count)
            _remaining = Cardinal(
                _remaining.rawValue >= consumed ? _remaining.rawValue - consumed : 0
            )
        }
        return try _base.next(maximumCount: maximumCount)
    }
}
