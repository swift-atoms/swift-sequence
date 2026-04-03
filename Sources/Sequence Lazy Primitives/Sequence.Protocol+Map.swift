extension Sequence.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Returns a lazy sequence that transforms each element.
    ///
    /// ```swift
    /// let doubled = source.map { $0 * 2 }
    /// let result = doubled.collect()  // [2, 4, 6]
    /// ```
    ///
    /// `@_lifetime(copy self)` — the returned wrapper's lifetime is
    /// derived from the consumed `self`. Available on all conformers
    /// (including `Copyable` + `Escapable`) because `~Copyable` &
    /// `~Escapable` suppression is permissive.
    ///
    /// `Element: Copyable` is required because the transform closure
    /// takes elements by value.
    ///
    /// - Parameter transform: A closure that transforms an element.
    /// - Returns: A lazy `Sequence.Map` wrapping this sequence.
    @_lifetime(copy self)
    @inlinable
    public consuming func map<Output>(
        _ transform: @escaping (Element) -> Output
    ) -> Sequence.Map<Self, Output> {
        Sequence.Map(_base: self, _transform: transform)
    }
}
