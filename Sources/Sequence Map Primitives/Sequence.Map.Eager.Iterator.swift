public import Iterator_Protocol

extension Sequence.Map.Eager where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Map.Eager` that transforms each base element.
    ///
    /// A scalar iterator over the foundation `Iterator.`Protocol`` — `next()`
    /// pulls one element from the base iterator and applies the transform.
    /// Element-transforming combinators are scalar by nature (one base element
    /// in, one transformed element out), so no bulk `nextSpan` and no unsafe
    /// span construction is needed.
    ///
    /// ## Suppression
    ///
    /// - `~Copyable` because the base iterator may be `~Copyable`.
    /// - `~Escapable` because its lifetime is derived from the base
    ///   iterator (via `@_lifetime(copy _base)`).
    public struct Iterator: ~Copyable, ~Escapable, Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _transform: (Base.Element) -> Output

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _transform: @escaping (Base.Element) -> Output)
        {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map.Eager.Iterator where Base: ~Copyable & ~Escapable {
    /// The element type produced by this iterator.
    public typealias Element = Output

    /// Returns the next transformed element, or `nil` when iteration completes.
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Output? {
        guard let element = try _base.next() else { return nil }
        return _transform(element)
    }
}
