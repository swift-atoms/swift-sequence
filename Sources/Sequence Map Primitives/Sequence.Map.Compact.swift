extension Sequence.Map where Base: ~Copyable & ~Escapable, Base.Element: Copyable {
    // `Output` stays Escapable — see the World-boundary note on `Sequence.Map.Eager`
    // (borrowed-view transforms are World-B keep-and-lend, Stage B).
    /// Lazy wrapper that transforms and filters elements in a single
    /// pass.
    ///
    /// Created via `source.map.compact { transform }` or via the bridging
    /// method `source.compactMap { transform }`. The transform returns
    /// `Optional`; `nil` results are skipped.
    public struct Compact<Output>: ~Copyable, ~Escapable {
        @usableFromInline
        var _base: Base  // var per the [compiler-bug workaround] noted on Sequence.Map.

        @usableFromInline
        let _transform: (Base.Element) -> Output?

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base, _transform: @escaping (Base.Element) -> Output?) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map.Compact: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.Map.Compact: Escapable where Base: Escapable & ~Copyable {}

extension Sequence.Map.Compact: Sequenceable where Base: ~Copyable & ~Escapable {
    /// The element type produced by this sequence (non-`nil` results of the transform).
    public typealias Element = Output

    /// Returns the iterator that yields each non-`nil` transformed element of the base.
    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _transform: _transform)
    }
}
