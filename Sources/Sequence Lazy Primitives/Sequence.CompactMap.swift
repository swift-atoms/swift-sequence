extension Sequence {
    /// Lazy wrapper that transforms and filters elements in a single
    /// pass.
    ///
    /// Created by calling `.compactMap { }` on a `Sequence.Protocol`
    /// conformer. The transform returns `Optional`; `nil` results are
    /// skipped.
    ///
    /// ```swift
    /// let parsed = source.compactMap { Int($0) }
    /// let result = parsed.collect()  // [1, 3] from ["1", "two", "3"]
    /// ```
    ///
    /// ## Suppression Pattern
    ///
    /// Same full suppression + conditional restoration as
    /// `Sequence.Map`. See `Sequence.Map` for the canonical pattern
    /// documentation.
    ///
    /// ### Constraints
    ///
    /// `Base.Element: Copyable` is required because the transform
    /// closure takes `Base.Element` by value.
    ///
    /// Iterator uses the heap buffer strategy.
    public struct CompactMap<Base: Sequence.`Protocol` & ~Copyable & ~Escapable, Output>: ~Copyable, ~Escapable
    where Base.Element: Copyable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        let _transform: (Base.Element) -> Output?

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base, _transform: @escaping (Base.Element) -> Output?) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.CompactMap: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.CompactMap: Escapable where Base: Escapable & ~Copyable {}

extension Sequence.CompactMap: Sequence.`Protocol` where Base: ~Copyable & ~Escapable {
    public typealias Element = Output

    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _transform: _transform)
    }
}
