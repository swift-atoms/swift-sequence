public import Index_Primitives

extension Sequence.`Protocol` where Self: ~Copyable & ~Escapable {
    /// Returns a lazy sequence that takes the first `count` elements.
    ///
    /// ```swift
    /// let head = source.prefix(first: Cardinal(3))
    /// let result = head.collect()  // [1, 2, 3]
    /// ```
    ///
    /// `@_lifetime(copy self)` — the returned wrapper's lifetime is
    /// derived from the consumed `self`. Available on all conformers
    /// because `~Copyable` & `~Escapable` suppression is permissive.
    ///
    /// No `Element: Copyable` constraint — element-preserving, does
    /// not inspect elements.
    ///
    /// - Parameter count: The number of elements to take.
    /// - Returns: A lazy `Sequence.Prefix.First` wrapping this
    ///   sequence.
    @_lifetime(copy self)
    @inlinable
    public consuming func prefix(first count: Cardinal) -> Sequence.Prefix.First<Self> {
        Sequence.Prefix.First(_base: self, _count: count)
    }
}

extension Sequence.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Returns a lazy sequence that takes leading elements while the
    /// predicate holds.
    ///
    /// ```swift
    /// let head = source.prefix(while: { $0 < 4 })
    /// let result = head.collect()  // [1, 2, 3]
    /// ```
    ///
    /// `@_lifetime(copy self)` — the returned wrapper's lifetime is
    /// derived from the consumed `self`.
    ///
    /// `Element: Copyable` is required because the predicate closure
    /// takes elements by value.
    ///
    /// - Parameter predicate: A closure that returns `true` for
    ///   elements to include.
    /// - Returns: A lazy `Sequence.Prefix.While` wrapping this
    ///   sequence.
    @_lifetime(copy self)
    @inlinable
    public consuming func prefix(
        while predicate: @escaping (Element) -> Bool
    ) -> Sequence.Prefix.While<Self> {
        Sequence.Prefix.While(_base: self, _predicate: predicate)
    }
}
