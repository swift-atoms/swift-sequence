extension Sequence {
    /// Lazy wrapper that filters elements of a base sequence by a
    /// predicate.
    ///
    /// Created by calling `.filter { }` on a `Sequence.Protocol`
    /// conformer. Conforms to `Sequence.Protocol`, enabling further
    /// chaining.
    ///
    /// ```swift
    /// let evens = source.filter { $0 % 2 == 0 }
    /// let result = evens.collect()  // [2, 4, 6]
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
    /// Iterator uses the heap buffer strategy.
    public struct Filter<Base: Sequence.`Protocol` & ~Copyable & ~Escapable>: ~Copyable, ~Escapable
    where Base.Element: Copyable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
        }
    }
}

extension Sequence.Filter: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.Filter: Escapable where Base: Escapable & ~Copyable {}

extension Sequence.Filter: Sequence.`Protocol` where Base: ~Copyable & ~Escapable {
    public typealias Element = Base.Element

    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _predicate: _predicate)
    }
}
