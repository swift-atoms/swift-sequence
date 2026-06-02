public import Iterator_Protocol

extension Sequence.Map.Compact where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Map.Compact` — a scalar iterator that applies
    /// the transform to each base element and skips `nil` results.
    ///
    /// Over the foundation `Iterator.`Protocol``: `next()` advances the base
    /// until the transform yields a non-`nil` value. Same scalar shape as
    /// `Sequence.Map.Eager.Iterator`.
    public struct Iterator: ~Copyable, ~Escapable, Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _transform: (Base.Element) -> Output?

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base.Iterator, _transform: @escaping (Base.Element) -> Output?) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map.Compact.Iterator where Base: ~Copyable & ~Escapable {
    /// The element type produced by this iterator (non-`nil` results of the transform).
    public typealias Element = Output

    /// Returns the next non-`nil` transformed element, or `nil` when iteration completes.
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Output? {
        while let element = try _base.next() {
            if let transformed = _transform(element) {
                return transformed
            }
        }
        return nil
    }
}
