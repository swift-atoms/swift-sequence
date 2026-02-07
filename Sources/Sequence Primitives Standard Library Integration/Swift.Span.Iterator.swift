public import Index_Primitives

extension Swift.Span {
    /// An iterator that produces single elements from a borrowed span.
    ///
    /// `Swift.Span<Element>.Iterator` provides element-at-a-time iteration
    /// over a span. The iterator is `~Escapable` and borrows from the span.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let array = [10, 20, 30]
    /// let span = array.span
    ///
    /// var iterator = Swift.Span<Int>.Iterator(span: span)
    /// while let element = iterator.next() {
    ///     print(element)  // 10, 20, 30
    /// }
    /// ```
    ///
    /// ## Batch Access
    ///
    /// For batch access returning sub-spans, use ``Iterator/Batch`` instead.
    @safe
    public struct Iterator: ~Escapable, ~Copyable {
        @usableFromInline
        let _span: Swift.Span<Element>

        @usableFromInline
        var _position: Ordinal

        /// Creates an iterator over the given span.
        ///
        /// - Parameter span: The span to iterate over.
        @inlinable
        @_lifetime(copy span)
        public init(span: Swift.Span<Element>) {
            self._span = span
            self._position = .zero
        }

        /// Whether the iterator has no remaining elements.
        @inlinable
        public var isEmpty: Bool {
            _position >= Cardinal(UInt(_span.count))
        }

        /// The number of remaining elements.
        @inlinable
        public var remaining: Cardinal {
            let total = Cardinal(UInt(_span.count))
            let consumed = Cardinal(_position.rawValue)
            return total.subtract.saturating(consumed)
        }

        /// Returns the next element, or `nil` if exhausted.
        ///
        /// - Returns: The next element, or `nil`.
        @inlinable
        @_lifetime(self: immortal)
        public mutating func next() -> Element? {
            guard _position < Cardinal(UInt(_span.count)) else { return nil }
            let element = _span[Int(bitPattern: _position)]
            _position = _position.successor.saturating()
            return element
        }
    }
}
