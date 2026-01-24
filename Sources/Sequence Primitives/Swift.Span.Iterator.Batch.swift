extension Swift.Span.Iterator {
    /// A batch iterator that produces sub-spans from a borrowed span.
    ///
    /// Unlike the single-element ``Swift/Span/Iterator``, this returns
    /// `Span<Element>` chunks via `nextSpan(maximumCount:)`.
    ///
    /// `Batch` implements `Sequence.Iterator.Borrowing.Protocol` for use
    /// with `Sequence.Borrowing.Protocol` containers.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let array = [10, 20, 30, 40, 50]
    /// let span = array.span
    ///
    /// var iterator = Swift.Span<Int>.Iterator.Batch(span: span)
    ///
    /// let batch1 = iterator.nextSpan(maximumCount: 2)  // [10, 20]
    /// let batch2 = iterator.nextSpan(maximumCount: 2)  // [30, 40]
    /// let batch3 = iterator.nextSpan(maximumCount: 2)  // [50]
    /// let batch4 = iterator.nextSpan(maximumCount: 2)  // empty
    /// ```
    @safe
    public struct Batch: ~Escapable, ~Copyable,
        Sequence.Iterator.Borrowing.`Protocol`
    {
        @usableFromInline
        let _span: Swift.Span<Element>

        @usableFromInline
        var _position: Int

        /// Creates an iterator over the given span.
        ///
        /// - Parameter span: The span to iterate over in batches.
        @inlinable
        @_lifetime(copy span)
        public init(span: Swift.Span<Element>) {
            self._span = span
            self._position = 0
        }

        /// Whether the iterator has no remaining elements.
        @inlinable
        public var isEmpty: Bool { _position >= _span.count }

        /// The number of remaining elements.
        @inlinable
        public var remaining: Int { _span.count - _position }

        /// Returns the next batch of elements as a span.
        ///
        /// Returns up to `maximumCount` elements. Returns an empty span
        /// when exhausted.
        ///
        /// - Parameter maximumCount: Maximum elements to return.
        /// - Returns: A span containing the next batch.
        @inlinable
        @_lifetime(copy self)
        public mutating func nextSpan(maximumCount: Int) -> Swift.Span<Element> {
            let count = min(maximumCount, _span.count - _position)
            guard count > 0 else { return _span.extracting(first: 0) }
            let result = _span
                .extracting(first: _position + count)
                .extracting(droppingFirst: _position)
            _position += count
            return result
        }

        /// Advances past elements without returning them.
        ///
        /// - Parameter maximumOffset: Maximum number of elements to skip.
        /// - Returns: The actual number of elements skipped.
        @inlinable
        @_lifetime(self: immortal)
        public mutating func skip(by maximumOffset: Int) -> Int {
            let count = min(maximumOffset, _span.count - _position)
            _position += count
            return count
        }
    }
}
