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
    public struct Iterator: ~Escapable, ~Copyable,
        Sequence.Iterator.`Protocol`
    {
        @usableFromInline
        let _span: Swift.Span<Element>

        @usableFromInline
        var _position: Ordinal

        @usableFromInline
        let _count: Cardinal

        /// Creates an iterator over the given span.
        ///
        /// - Parameter span: The span to iterate over.
        @inlinable
        @_lifetime(copy span)
        public init(span: Swift.Span<Element>) {
            self._span = span
            self._position = .zero
            self._count = Cardinal(UInt(bitPattern: span.count))
        }

        /// Whether the iterator has no remaining elements.
        @inlinable
        public var isEmpty: Bool {
            _position >= _count
        }

        /// The number of remaining elements.
        @inlinable
        public var remaining: Cardinal {
            _count.subtract.saturating(Cardinal(_position))
        }

        /// Returns the next batch of elements as a span.
        ///
        /// - Parameter maximumCount: Maximum elements to return.
        /// - Returns: A span containing the next batch.
        @inlinable
        @_lifetime(&self)
        public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Element> {
            let take = min(maximumCount, remaining)
            guard take > .zero else { return _span.extracting(first: 0) }

            let result =
                _span
                .extracting(droppingFirst: Cardinal(_position))
                .extracting(first: take)

            _position = _position.advance.saturating(by: take)
            return result
        }

        /// Returns the next element, or `nil` if exhausted.
        ///
        /// Performance override — avoids span construction for single elements.
        ///
        /// - Returns: The next element, or `nil`.
        @inlinable
        @_lifetime(self: immortal)
        public mutating func next() -> Element? {
            guard _position < _count else { return nil }
            let element = _span[_position]
            _position = _position.successor.saturating()
            return element
        }
    }
}
