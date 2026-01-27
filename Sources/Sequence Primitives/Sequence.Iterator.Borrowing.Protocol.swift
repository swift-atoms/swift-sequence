public import Index_Primitives

extension Sequence.Iterator.Borrowing {
    /// A protocol for iterators that return spans of elements.
    ///
    /// `Sequence.Iterator.Borrowing.Protocol` enables efficient batch iteration
    /// by returning `Span<Element>` chunks rather than individual elements.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var iterator = container.makeIterator()
    /// while true {
    ///     let span = iterator.nextSpan(maximumCount: Cardinal.Count(UInt.max))
    ///     if span.isEmpty { break }
    ///     for i in span.indices {
    ///         process(span[i])
    ///     }
    /// }
    /// ```
    ///
    /// ## Core Operations
    ///
    /// | Method | Description |
    /// |--------|-------------|
    /// | `nextSpan(maximumCount:)` | Returns next batch as span |
    /// | `skip(by:)` | Advances without returning elements |
    ///
    /// ## Lifetime Semantics
    ///
    /// The returned span borrows from the iterator via `@_lifetime(&self)`.
    /// This ensures the span cannot outlive the iterator.
    ///
    /// ## SE-0427 Limitation
    ///
    /// The `Element` type implicitly requires `Copyable` per SE-0427.
    public protocol `Protocol`: ~Copyable, ~Escapable {
        /// The type of element in the span.
        ///
        /// > Note: Implicitly requires `Copyable` per SE-0427.
        associatedtype Element

        /// Returns the next batch of elements as a span.
        ///
        /// Returns up to `maximumCount` elements as a contiguous span.
        /// Returns an empty span when the sequence is exhausted.
        ///
        /// - Parameter maximumCount: Maximum number of elements to return.
        /// - Returns: A span containing the next batch of elements.
        @_lifetime(&self)
        mutating func nextSpan(maximumCount: Cardinal.Count) -> Swift.Span<Element>

        /// Advances past elements without returning them.
        ///
        /// - Parameter maximumCount: Maximum number of elements to skip.
        /// - Returns: The actual number of elements skipped.
        @_lifetime(self: immortal)
        mutating func skip(by maximumCount: Cardinal.Count) -> Cardinal.Count
    }
}

// MARK: - Default Implementation

extension Sequence.Iterator.Borrowing.`Protocol` {
    /// Default implementation that skips by consuming spans.
    ///
    /// Conforming types may provide optimized implementations.
    @inlinable
    @_lifetime(self: immortal)
    public mutating func skip(by maximumCount: Cardinal.Count) -> Cardinal.Count {
        var remaining = maximumCount
        while remaining > .zero {
            let span = nextSpan(maximumCount: remaining)
            if span.isEmpty { break }
            remaining = remaining.subtract.saturating(Cardinal.Count(UInt(span.count)))
        }
        return maximumCount.subtract.saturating(remaining)
    }
}

// MARK: - Typealias for Ergonomics

extension Sequence.Iterator {
    /// Alias for ``Sequence/Iterator/Borrowing/Protocol``.
    ///
    /// Provided for ergonomic conformance declarations:
    /// ```swift
    /// extension MyIterator: Sequence.Iterator.BorrowingIterating { ... }
    /// ```
    public typealias BorrowingIterating = Sequence.Iterator.Borrowing.`Protocol`
}
