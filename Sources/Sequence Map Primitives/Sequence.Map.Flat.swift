extension Sequence.Map where Base: ~Copyable & ~Escapable, Base.Element: Copyable {
    /// Lazy wrapper that transforms elements into sequences and flattens
    /// them into a single level.
    ///
    /// Created via `source.map.flat { transform }` or via the bridging
    /// method `source.flatMap { transform }`. The transform returns a
    /// sequence whose elements are concatenated.
    public struct Flat<InnerSequence: Sequenceable>: ~Copyable, ~Escapable
    where InnerSequence.Element: Copyable, InnerSequence.Iterator: Escapable {
        @usableFromInline
        var _base: Base  // var per the [compiler-bug workaround] noted on Sequence.Map.

        @usableFromInline
        let _transform: (Base.Element) -> InnerSequence

        @_lifetime(copy _base)
        @inlinable
        package init(
            _base: consuming Base,
            _transform: @escaping (Base.Element) -> InnerSequence
        ) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map.Flat: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.Map.Flat: Escapable where Base: Escapable & ~Copyable {}

extension Sequence.Map.Flat: Sequenceable
where Base: ~Copyable & ~Escapable, InnerSequence.Iterator.Failure == Base.Iterator.Failure {
    /// The element type produced by this sequence (the inner sequence's element type, flattened).
    public typealias Element = InnerSequence.Element

    /// Returns the iterator that yields elements from each inner sequence in turn.
    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _transform: _transform)
    }
}
