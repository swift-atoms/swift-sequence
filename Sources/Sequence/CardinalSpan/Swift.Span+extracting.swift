#if CardinalSpan
public import Cardinal
public import Ordinal

extension Swift.Span where Element: Copyable {

    @inlinable
    @_lifetime(copy self)
    public subscript(position: Ordinal) -> Element {
        self[Int(clamping: position.rawValue)]
    }
}

extension Swift.Span {

    @inlinable
    @_lifetime(copy self)
    public func extracting(first count: Cardinal) -> Self {
        self.extracting(first: Int(clamping: count.rawValue))
    }

    @inlinable
    @_lifetime(copy self)
    public func extracting(droppingFirst count: Cardinal) -> Self {
        self.extracting(droppingFirst: Int(clamping: count.rawValue))
    }
}
#endif
