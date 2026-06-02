public import Index_Primitives

extension Sequence.Drop {
    /// Lazy wrapper that skips the first N elements of a base sequence.
    ///
    /// Created by calling `.drop(first:)` on a `Sequence.Protocol`
    /// conformer. Uses the simpler lazy wrapper pattern — no
    /// `Element: Copyable` constraint because it is element-preserving
    /// (doesn't inspect elements).
    ///
    /// ```swift
    /// let tail = source.drop(first: Cardinal(2))
    /// let result = tail.collect()  // [3, 4, 5] from [1, 2, 3, 4, 5]
    /// ```
    ///
    /// ## Suppression Pattern
    ///
    /// Same full suppression + conditional restoration as
    /// `Sequence.Map`:
    /// - `~Copyable, ~Escapable` on the struct
    /// - `Copyable where Base: Copyable & ~Escapable`
    /// - `Escapable where Base: Escapable & ~Copyable`
    /// - Conformance extension with
    ///   `where Base: ~Copyable & ~Escapable`
    ///
    /// Iterator uses forward-to-base (zero allocation).
    public struct First<Base: Sequenceable & ~Copyable & ~Escapable>: ~Copyable, ~Escapable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        let _count: Cardinal

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base, _count: Cardinal) {
            self._base = _base
            self._count = _count
        }
    }
}

extension Sequence.Drop.First: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.Drop.First: Escapable where Base: Escapable & ~Copyable {}

extension Sequence.Drop.First: Sequenceable where Base: ~Copyable & ~Escapable {
    /// The element type produced by this lazy sequence (the same element type as the base).
    public typealias Element = Base.Element

    /// Creates a fresh iterator that skips the first stored count of base elements.
    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _remaining: _count)
    }
}
