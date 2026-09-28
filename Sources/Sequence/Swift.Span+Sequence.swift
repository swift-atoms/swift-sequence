public import Cardinal
public import Ordinal

import Carrier
public import Iterator

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
