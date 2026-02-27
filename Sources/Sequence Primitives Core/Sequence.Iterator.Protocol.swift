public import Index_Primitives

extension Sequence.Iterator {
    /// The unified iterator protocol for span-based element production.
    ///
    /// `nextSpan(maximumCount:)` is the sole protocol requirement. All
    /// iteration — `next()`, `skip(by:)`, `forEach`, `collect()` — is
    /// built on top of span-based batching.
    ///
    /// ## Conforming to Sequence.Iterator.Protocol
    ///
    /// Return up to `maximumCount` elements as a contiguous
    /// `Span<Element>`. Return an empty span when exhausted.
    ///
    /// ### Two Iterator Strategies
    ///
    /// **Heap buffer** (element-transforming: `Map`, `Filter`,
    /// `CompactMap`):
    ///
    /// Allocate a single-element `UnsafeMutablePointer<Output>` in
    /// `init`, write transformed elements into it, return 1-element
    /// spans, clean up in `deinit`. One allocation per iterator lifetime.
    ///
    /// ```swift
    /// let buf = unsafe UnsafeMutablePointer<Output>.allocate(capacity: 1)
    /// // In nextSpan:
    /// unsafe buf.initialize(to: transformedValue)
    /// let span = unsafe Span(_unsafeStart: UnsafePointer(buf), count: 1)
    /// return unsafe _overrideLifetime(span, mutating: &self)
    /// // In deinit:
    /// if _bufferInitialized { _mutableBuffer.deinitialize(count: 1) }
    /// _mutableBuffer.deallocate()
    /// ```
    ///
    /// Use `_overrideLifetime(span, mutating: &self)` to chain the
    /// `Span`'s lifetime to the iterator.
    ///
    /// **Forward-to-base** (element-preserving: `Drop.First`,
    /// `Drop.While`, `Prefix.First`, `Prefix.While`):
    ///
    /// Store a `Base.Iterator`, forward `nextSpan` calls directly to it
    /// (possibly with count clamping or skip phases). Zero allocation —
    /// the `Span` borrows from the base iterator's storage.
    ///
    /// ```swift
    /// let clamped = min(maximumCount, _remaining)
    /// let span = _base.nextSpan(maximumCount: clamped)
    /// _remaining = _remaining.subtract.saturating(Cardinal(UInt(span.count)))
    /// return span
    /// ```
    ///
    /// ### `@_lifetime(&self)`
    ///
    /// The returned `Span` borrows from the iterator. The caller's
    /// borrow of the iterator must outlive the `Span`. This is how
    /// span-based lending works — the iterator owns (or borrows) the
    /// storage, the span borrows it.
    ///
    /// ### Overriding `next()`
    ///
    /// The default `next()` calls `nextSpan(maximumCount: 1)` which
    /// constructs a `Span`. `Span`'s `_unsafeStart` init has overhead
    /// (alignment check, `mark_dependence`, COW). Conformers **should**
    /// override `next()` with a direct implementation for single-element
    /// access. Use `@_lifetime(self: immortal)` on the override (returns
    /// an owned `Copyable` value, not borrowed).
    ///
    /// ### Overriding `skip(by:)`
    ///
    /// The default loops over `nextSpan` calls. If the iterator can skip
    /// more efficiently (e.g., pointer arithmetic), override it.
    ///
    /// ### `~Copyable`, `~Escapable`
    ///
    /// Iterators with `deinit` (heap buffer) are `~Copyable`. Iterators
    /// that borrow from their sequence are `~Escapable`. Both
    /// suppressions are on the protocol. Conformers providing plain
    /// `Copyable` + `Escapable` iterators (like wrapping
    /// `Array.Iterator`) satisfy this automatically — no annotations
    /// needed.
    ///
    /// ### Empty Span Convention
    ///
    /// When exhausted, return an empty span. For heap buffer iterators,
    /// `unsafe Span(_unsafeStart: bufferPtr, count: 0)` works (the
    /// pointer is valid, count is 0). For forward-to-base iterators,
    /// forwarding with `maximumCount: .zero` returns the base's empty
    /// span.
    ///
    /// ## Default Extensions
    ///
    /// | Method | Constraint | Description |
    /// |--------|------------|-------------|
    /// | `next()` | `Element: Copyable` | Single element via `nextSpan(maximumCount: 1)` |
    /// | `skip(by:)` | None | Advances without returning elements |
    ///
    /// ## Relationship to `Swift.IteratorProtocol`
    ///
    /// | Aspect | `Swift.IteratorProtocol` | `Sequence.Iterator.Protocol` |
    /// |--------|--------------------------|------------------------------|
    /// | Iterator `~Copyable` | No | Yes |
    /// | Element `~Copyable` | No | Yes |
    /// | Span-based | No | Yes (sole requirement) |
    /// | `for-in` syntax | Yes | No |
    public protocol `Protocol`: ~Copyable, ~Escapable {
        /// The type of element produced by the iterator.
        associatedtype Element: ~Copyable

        /// Returns the next batch of elements as a contiguous span.
        ///
        /// Return up to `maximumCount` elements. The span borrows from
        /// the iterator via `@_lifetime(&self)` — the caller's borrow of
        /// the iterator must outlive the span. Return an empty span when
        /// exhausted.
        ///
        /// - Parameter maximumCount: Maximum number of elements to
        ///   return.
        /// - Returns: A span containing the next batch of elements, or
        ///   an empty span when exhausted.
        @_lifetime(&self)
        mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Element>
    }
}

// MARK: - Default next() for Copyable elements

extension Sequence.Iterator.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Returns the next element, or `nil` if exhausted.
    ///
    /// Default implementation via `nextSpan(maximumCount: 1)`.
    /// Conformers **should** override for performance — the default
    /// constructs a `Span` which has overhead (alignment check,
    /// `mark_dependence`). Use `@_lifetime(self: immortal)` on the
    /// override (returns an owned `Copyable` value, not borrowed).
    @inlinable
    @_lifetime(self: immortal)
    public mutating func next() -> Element? {
        let span = nextSpan(maximumCount: Cardinal(1))
        return span.isEmpty ? nil : span[0]
    }
}

// MARK: - Default skip(by:)

extension Sequence.Iterator.`Protocol` where Self: ~Copyable & ~Escapable {
    /// Advances past elements without returning them.
    ///
    /// Default implementation that loops over `nextSpan` calls.
    /// Conformers may override if they can skip more efficiently
    /// (e.g., pointer arithmetic).
    ///
    /// - Parameter maximumCount: Maximum number of elements to skip.
    /// - Returns: The actual number of elements skipped.
    @inlinable
    @_lifetime(self: immortal)
    public mutating func skip(by maximumCount: Cardinal) -> Cardinal {
        var remaining = maximumCount
        while remaining > .zero {
            let span = nextSpan(maximumCount: remaining)
            if span.isEmpty { break }
            remaining = remaining.subtract.saturating(Cardinal(UInt(span.count)))
        }
        return maximumCount.subtract.saturating(remaining)
    }
}
