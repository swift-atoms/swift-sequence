extension Sequence.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Returns a lazy sequence containing only elements that satisfy
    /// the predicate.
    ///
    /// ```swift
    /// let evens = source.filter { $0 % 2 == 0 }
    /// let result = evens.collect()  // [2, 4, 6]
    /// ```
    ///
    /// `@_lifetime(copy self)` — the returned wrapper's lifetime is
    /// derived from the consumed `self`. Available on all conformers
    /// because `~Copyable` & `~Escapable` suppression is permissive.
    ///
    /// `Element: Copyable` is required because the predicate closure
    /// takes elements by value.
    ///
    /// - Parameter predicate: A closure that returns `true` for
    ///   elements to include.
    /// - Returns: A lazy `Sequence.Filter` wrapping this sequence.
    @_lifetime(copy self)
    @inlinable
    public consuming func filter(
        _ predicate: @escaping (Element) -> Bool
    ) -> Sequence.Filter<Self> {
        Sequence.Filter(_base: self, _predicate: predicate)
    }
}
