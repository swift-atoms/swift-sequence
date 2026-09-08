public import Cardinal
public import Ordinal

extension Swift.Span where Element: Copyable {

    @inlinable
    @_lifetime(copy self)
    public subscript(position: Ordinal) -> Element {
        self[Int(bitPattern: position.rawValue)]
    }
}

extension Swift.Span {

    @inlinable
    @_lifetime(copy self)
    public func extracting(first count: Cardinal) -> Self {
        self.extracting(first: Int(bitPattern: count.rawValue))
    }

    @inlinable
    @_lifetime(copy self)
    public func extracting(droppingFirst count: Cardinal) -> Self {
        self.extracting(droppingFirst: Int(bitPattern: count.rawValue))
    }
}

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
