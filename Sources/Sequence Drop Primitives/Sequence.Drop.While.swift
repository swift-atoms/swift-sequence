extension Sequence.Drop {
    /// Lazy wrapper that skips leading elements while a predicate
    /// holds.
    ///
    /// Created by calling `.drop(while:)` on a `Sequence.Protocol`
    /// conformer. Once the predicate returns `false`, all remaining
    /// elements pass through.
    ///
    /// ```swift
    /// let tail = source.drop(while: { $0 < 3 })
    /// let result = tail.collect()  // [3, 4, 5] from [1, 2, 3, 4, 5]
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
    /// two-phase scan-then-forward approach.
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

extension Sequence.Drop.While: Copyable
where Base: Copyable & ~Escapable, Base.Element: Escapable {}
extension Sequence.Drop.While: Escapable
where Base: Escapable & ~Copyable, Base.Element: Escapable {}

extension Sequence.Drop.While: Sequenceable
where Base: ~Copyable & ~Escapable, Base.Element: Escapable {
    /// The element type produced by this lazy sequence (the same element type as the base).
    public typealias Element = Base.Element

    /// Creates a fresh iterator that skips leading base elements while the predicate holds.
    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _predicate: _predicate)
    }
}
