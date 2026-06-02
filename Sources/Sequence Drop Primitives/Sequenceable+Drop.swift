public import Index_Primitives

extension Sequenceable where Self: ~Copyable & ~Escapable {
    /// Returns a lazy sequence that skips the first `count` elements.
    ///
    /// ```swift
    /// let tail = source.drop(first: Cardinal(2))
    /// let result = tail.collect()  // [3, 4, 5]
    /// ```
    ///
    /// `@_lifetime(copy self)` — the returned wrapper's lifetime is
    /// derived from the consumed `self`. Available on all conformers
    /// because `~Copyable` & `~Escapable` suppression is permissive.
    ///
    /// No `Element: Copyable` constraint — element-preserving, does
    /// not inspect elements.
    ///
    /// - Parameter count: The number of elements to skip.
    /// - Returns: A lazy `Sequence.Drop.First` wrapping this sequence.
    @_lifetime(copy self)
    @inlinable
    public consuming func drop(first count: Cardinal) -> Sequence.Drop.First<Self> {
        Sequence.Drop.First(_base: self, _count: count)
    }
}

extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Returns a lazy sequence that skips leading elements while the
    /// predicate holds.
    ///
    /// ```swift
    /// let tail = source.drop(while: { $0 < 3 })
    /// let result = tail.collect()  // [3, 4, 5]
    /// ```
    ///
    /// `@_lifetime(copy self)` — the returned wrapper's lifetime is
    /// derived from the consumed `self`.
    ///
    /// `Element: Copyable` is required because the predicate closure
    /// takes elements by value.
    ///
    /// - Parameter predicate: A closure that returns `true` for
    ///   elements to skip.
    /// - Returns: A lazy `Sequence.Drop.While` wrapping this sequence.
    @_lifetime(copy self)
    @inlinable
    public consuming func drop(
        while predicate: @escaping (Element) -> Bool
    ) -> Sequence.Drop.While<Self> {
        Sequence.Drop.While(_base: self, _predicate: predicate)
    }
}
