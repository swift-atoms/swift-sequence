public import Cardinal
public import Carrier_Protocol
public import Iterator_Chunk
public import Ordinal

extension Swift.Span {

    @safe
    public struct Iterator: ~Escapable, ~Copyable,
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

extension Swift.Span.Iterator {

    public typealias Failure = Never

    @inlinable
    public var isEmpty: Bool {
        _position.rawValue >= _count.rawValue
    }

    @inlinable
    public var remaining: Cardinal {
        guard _position.rawValue < _count.rawValue else { return Cardinal(0) }
        return Cardinal(_count.rawValue - _position.rawValue)
    }

    @inlinable
    @_lifetime(&self)
    public mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) -> Swift.Span<Element> {
        let take = min(maximumCount.underlying, remaining)
        guard take > Cardinal(0) else { return _span.extracting(first: 0) }

        let result =
            _span
            .extracting(droppingFirst: Cardinal(_position.rawValue))
            .extracting(first: take)

        _position = Ordinal(_position.rawValue + take.rawValue)
        return result
    }

    @inlinable
    @_lifetime(self: immortal)
    public mutating func next() -> Element? {
        guard _position.rawValue < _count.rawValue else { return nil }
        let element = _span[_position]
        _position = Ordinal(_position.rawValue + 1)
        return element
    }
}
