extension Sequence.Prefix {
    /// Lazy wrapper that takes leading elements while a predicate
    /// holds.
    ///
    /// Created by calling `.prefix(while:)` on a `Sequence.Protocol`
    /// conformer. Once the predicate returns `false`, the sequence is
    /// exhausted.
    ///
    /// ```swift
    /// let head = source.prefix(while: { $0 < 4 })
    /// let result = head.collect()  // [1, 2, 3] from [1, 2, 3, 4, 5]
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
    /// `Base.Element: Copyable` is required because the predicate
    /// closure takes `Base.Element` by value.
    ///
    /// Iterator uses forward-to-base (zero allocation) with a
    /// scan-then-terminate approach.
    public struct While<
        Base: Sequenceable<Base.Element> & ~Copyable & ~Escapable
    >: ~Copyable, ~Escapable where Base.Element: Copyable & Escapable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
        }
    }
}

extension Sequence.Prefix.While: Copyable
where Base: Copyable & ~Escapable, Base.Element: Escapable {}
extension Sequence.Prefix.While: Escapable
where Base: Escapable & ~Copyable, Base.Element: Escapable {}

extension Sequence.Prefix.While: Sequenceable
where Base: ~Copyable & ~Escapable, Base.Element: Escapable {
    /// The element type produced by this lazy sequence (the same element type as the base).
    public typealias Element = Base.Element

    /// Creates a fresh iterator that yields leading base elements while the predicate holds.
    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _predicate: _predicate)
    }
}
