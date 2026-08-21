public import Index_Primitives
public import Iterator_Chunk_Primitives

extension Swift.Span.Iterator {

    @safe
    public struct Batch: ~Escapable, ~Copyable,
        __IteratorChunkProtocol
    {
        @usableFromInline
        let _span: Swift.Span<Element>

        @usableFromInline
        var _position: Ordinal

        @usableFromInline
        let _count: Cardinal

        @inlinable
        @_lifetime(copy span)
        public init(span: Swift.Span<Element>) {
            self._span = span
            self._position = .zero
            self._count = Cardinal(UInt(bitPattern: span.count))
        }
    }
}

extension Swift.Span.Iterator.Batch {

    public typealias Failure = Never

    @inlinable
    public var isEmpty: Bool {
        _position >= _count
    }

    @inlinable
    public var remaining: Cardinal {
        _count.subtract.saturating(Cardinal(_position))
    }

    @inlinable
    @_lifetime(&self)
    public mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) -> Swift.Span<Element> {
        let take = min(maximumCount.underlying, remaining)
        guard take > .zero else { return _span.extracting(first: 0) }

        let result =
            _span
            .extracting(droppingFirst: Cardinal(_position))
            .extracting(first: take)

        _position = _position.advance.saturating(by: take)
        return result
    }

    @inlinable
    @_lifetime(self: immortal)
    public mutating func skip(by maximumCount: Cardinal) -> Cardinal {
        let skip = min(maximumCount, remaining)
        _position = _position.advance.saturating(by: skip)
        return skip
    }
}
