public import Index_Primitives

extension Swift.Span.Iterator {
    /// A batch iterator that produces sub-spans from a borrowed span.
    ///
    /// Unlike the single-element ``Swift/Span/Iterator``, this returns
    /// `Span<Element>` chunks via `nextSpan(maximumCount:)`.
    ///
    /// `Batch` implements `Sequence.Iterator.Protocol` via `nextSpan`,
    /// returning sub-span batches.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let array = [10, 20, 30, 40, 50]
    /// let span = array.span
    ///
    /// var iterator = Swift.Span<Int>.Iterator.Batch(span: span)
    ///
    /// let batch1 = iterator.nextSpan(maximumCount: Cardinal(2))  // [10, 20]
    /// let batch2 = iterator.nextSpan(maximumCount: Cardinal(2))  // [30, 40]
    /// let batch3 = iterator.nextSpan(maximumCount: Cardinal(2))  // [50]
    /// let batch4 = iterator.nextSpan(maximumCount: Cardinal(2))  // empty
    /// ```
    @safe
    public struct Batch: ~Escapable, ~Copyable,
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
        /// - Parameter span: The span to iterate over in batches.
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
        /// Returns up to `maximumCount` elements. Returns an empty span
        /// when exhausted.
        ///
        /// - Parameter maximumCount: Maximum elements to return.
        /// - Returns: A span containing the next batch.
        @inlinable
        @_lifetime(&self)
        public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Element> {
            let take = min(maximumCount, remaining)
            guard take > .zero else { return _span.extracting(first: 0) }

            let result = _span
                .extracting(droppingFirst: Cardinal(_position))
                .extracting(first: take)

            _position = _position.advance.saturating(by: take)
            return result
        }

        /// Advances past elements without returning them.
        ///
        /// - Parameter maximumCount: Maximum number of elements to skip.
        /// - Returns: The actual number of elements skipped.
        @inlinable
        @_lifetime(self: immortal)
        public mutating func skip(by maximumCount: Cardinal) -> Cardinal {
            let skip = min(maximumCount, remaining)
            _position = _position.advance.saturating(by: skip)
            return skip
        }
    }
}
