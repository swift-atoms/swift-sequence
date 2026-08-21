public import Iterator_Protocol

extension Sequence.Filter where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Filter` — a scalar iterator that yields base
    /// elements matching the predicate.
    ///
    /// Over the foundation `Iterator.`Protocol``: `next()` advances the base
    /// until it finds a matching element.
    ///
    /// ## Suppression
    ///
    /// - `~Copyable` because the base iterator may be `~Copyable`.
    /// - `~Escapable` because its lifetime is derived from the base
    ///   iterator.
    public struct Iterator: ~Copyable, ~Escapable,
        Iterator_Primitive.Iterator.`Protocol`<Base.Element, Base.Iterator.Failure>
    {
        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
        }
    }
}

extension Sequence.Filter.Iterator where Base: ~Copyable & ~Escapable {
    /// The element type produced by this iterator (elements of the base that match the predicate).
    public typealias Element = Base.Element

    /// Returns the next matching element, or `nil` when iteration completes.
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Base.Element? {
        while let element = try _base.next() {
            if _predicate(element) {
                return element
            }
        }
        return nil
    }
}
