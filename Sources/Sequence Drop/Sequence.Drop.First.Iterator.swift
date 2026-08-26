public import Iterator_Chunk

extension Sequence.Drop.First
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {

    public struct Iterator: ~Copyable, ~Escapable,
        Iterator_Primitive.Iterator.`Protocol`<Base.Element, Base.Iterator.Failure>
    {
        @_implements(Iterator_Primitive.Iterator.`Protocol`,Element)
        public typealias ScalarElement = Base.Element

        @_implements(Iterator_Primitive.Iterator.`Protocol`,Failure)
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
        while _remaining > .zero {
            _remaining = _remaining.subtract.saturating(.one)
            switch try _base.next() {
            case .none: return nil
            case .some: continue
            }
        }
        return try _base.next()
    }
}

extension Sequence.Drop.First.Iterator:
    Iterator_Primitive.Iterator.Chunk.`Protocol`<Base.Element, Base.Iterator.Failure>
where
    Base: ~Copyable & ~Escapable,
    Base.Element: Escapable,
    Base.Iterator: Iterator_Primitive.Iterator.Chunk.`Protocol`<
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
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Base.Iterator.Failure) -> Swift.Span<Base.Element> {
        let maximumCount = maximumCount.underlying
        while _remaining > .zero {
            let span = try _base.next(maximumCount: _remaining)
            if span.isEmpty {
                return span
            }
            _remaining = _remaining.subtract.saturating(Cardinal(UInt(span.count)))
        }
        return try _base.next(maximumCount: maximumCount)
    }
}
