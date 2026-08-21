public import Cardinal_Primitives
public import Ordinal_Primitives

extension Swift.Span where Element: Copyable {

    @inlinable
    @_lifetime(copy self)
    public subscript(position: Ordinal) -> Element {
        self[Int(bitPattern: position)]
    }
}

extension Swift.Span {

    @inlinable
    @_lifetime(copy self)
    public func extracting(first count: Cardinal) -> Self {
        self.extracting(first: Int(bitPattern: count))
    }

    @inlinable
    @_lifetime(copy self)
    public func extracting(droppingFirst count: Cardinal) -> Self {
        self.extracting(droppingFirst: Int(bitPattern: count))
    }
}
