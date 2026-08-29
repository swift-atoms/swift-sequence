public import Cardinal
public import Cardinal_Carrier
public import Carrier_Protocol
public import Iterator_Chunk

extension Sequence.Prefix.While where Base: ~Copyable & ~Escapable {

    public struct Iterator: ~Copyable, ~Escapable,
        Iterator::Iterator.`Protocol`<Base.Element, Base.Iterator.Failure>
    {
        @_implements(Iterator::Iterator.`Protocol`,Element)
        public typealias ScalarElement = Base.Element

        @_implements(Iterator::Iterator.`Protocol`,Failure)
        public typealias ScalarFailure = Base.Iterator.Failure

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @usableFromInline
        var _done: Bool

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
            self._done = false
        }
    }
}

extension Sequence.Prefix.While.Iterator where Base: ~Copyable & ~Escapable {

    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        guard !_done else { return nil }
        guard let element = try _base.next() else { return nil }
        if _predicate(element) {
            return element
        }
        _done = true
        return nil
    }
}

extension Sequence.Prefix.While.Iterator:
    Iterator::Iterator.Chunk.`Protocol`<Base.Element, Base.Iterator.Failure>
where
    Base: ~Copyable & ~Escapable,
    Base.Element: Escapable,
    Base.Iterator: Iterator::Iterator.Chunk.`Protocol`<
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
        guard !_done else {
            return try _base.next(maximumCount: Cardinal.zero)
        }
        let span = try _base.next(maximumCount: maximumCount)
        if span.isEmpty {
            _done = true
            return span
        }
        for i in span.indices {
            if !_predicate(span[i]) {
                _done = true
                return span.extracting(first: i)
            }
        }
        return span
    }
}
