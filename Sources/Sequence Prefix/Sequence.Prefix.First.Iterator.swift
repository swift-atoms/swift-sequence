public import Iterator_Chunk

extension Sequence.Prefix.First
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {

    public struct Iterator: ~Copyable, ~Escapable,
        Iterator.Iterator.`Protocol`<Base.Element, Base.Iterator.Failure>
    {
        @_implements(Iterator.Iterator.`Protocol`,Element)
        public typealias ScalarElement = Base.Element

        @_implements(Iterator.Iterator.`Protocol`,Failure)
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

extension Sequence.Prefix.First.Iterator
where Base: ~Copyable & ~Escapable, Base.Element: ~Copyable & ~Escapable {

    @_lifetime(&self)
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        guard _remaining > .zero else { return nil }
        _remaining = _remaining.subtract.saturating(.one)
        return try _base.next()
    }
}

extension Sequence.Prefix.First.Iterator:
    Iterator.Iterator.Chunk.`Protocol`<Base.Element, Base.Iterator.Failure>
where
    Base: ~Copyable & ~Escapable,
    Base.Element: Escapable,
    Base.Iterator: Iterator.Iterator.Chunk.`Protocol`<
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
        guard _remaining > .zero else {
            return try _base.next(maximumCount: Cardinal.zero)
        }
        let clamped = min(maximumCount, _remaining)
        let span = try _base.next(maximumCount: clamped)
        _remaining = _remaining.subtract.saturating(Cardinal(UInt(span.count)))
        return span
    }
}
