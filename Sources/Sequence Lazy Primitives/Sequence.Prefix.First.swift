public import Index_Primitives

extension Sequence.Prefix {
    /// Lazy wrapper that takes the first N elements of a base sequence.
    ///
    /// Created by calling `.prefix(first:)` on a `Sequence.Protocol`
    /// conformer. Uses the simpler lazy wrapper pattern — no
    /// `Element: Copyable` constraint because it is element-preserving
    /// (doesn't inspect elements).
    ///
    /// ```swift
    /// let head = source.prefix(first: Cardinal(3))
    /// let result = head.collect()  // [1, 2, 3] from [1, 2, 3, 4, 5]
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
    /// Iterator uses forward-to-base (zero allocation) with count
    /// clamping.
    public struct First<Base: Sequence.`Protocol` & ~Copyable & ~Escapable>: ~Copyable, ~Escapable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        let _count: Cardinal

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base, _count: Cardinal) {
            self._base = _base
            self._count = _count
        }
    }
}

extension Sequence.Prefix.First: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.Prefix.First: Escapable where Base: Escapable & ~Copyable {}

extension Sequence.Prefix.First: Sequence.`Protocol` where Base: ~Copyable & ~Escapable {
    public typealias Element = Base.Element

    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _remaining: _count)
    }
}
