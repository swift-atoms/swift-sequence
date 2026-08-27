public import Cardinal
public import Iterator

extension Swift.Span.Iterator {

    @safe
    public struct Batch: ~Escapable, ~Copyable,
        __IteratorChunkProtocol
    {
        @usableFromInline
        let _span: Swift.Span<Element>

        @usableFromInline
        var _position: Int

        @usableFromInline
        let _count: Int

        @inlinable
        @_lifetime(copy span)
        public init(span: Swift.Span<Element>) {
            self._span = span
            self._position = 0
            self._count = span.count
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
        Cardinal(UInt(_count - _position))
    }

    @inlinable
    @_lifetime(&self)
    public mutating func next(
        maximumCount: Cardinal
    ) -> Swift.Span<Element> {
        let take = Swift.min(Int(clamping: maximumCount.rawValue), _count - _position)
        guard take > 0 else { return _span.extracting(first: 0) }

        let result =
            _span
            .extracting(droppingFirst: _position)
            .extracting(first: take)

        _position += take
        return result
    }

    @inlinable
    @_lifetime(self: immortal)
    public mutating func skip(by maximumCount: Cardinal) -> Cardinal {
        let skip = Swift.min(Int(clamping: maximumCount.rawValue), _count - _position)
        _position += skip
        return Cardinal(UInt(skip))
    }
}
