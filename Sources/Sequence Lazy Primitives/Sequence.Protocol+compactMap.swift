extension Sequence.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Returns a lazy sequence that transforms elements and removes
    /// `nil` results.
    ///
    /// ```swift
    /// let parsed = source.compactMap { Int($0) }
    /// let result = parsed.collect()  // [1, 3] from ["1", "two", "3"]
    /// ```
    ///
    /// `@_lifetime(copy self)` — the returned wrapper's lifetime is
    /// derived from the consumed `self`. Available on all conformers
    /// because `~Copyable` & `~Escapable` suppression is permissive.
    ///
    /// `Element: Copyable` is required because the transform closure
    /// takes elements by value.
    ///
    /// - Parameter transform: A closure that returns an optional
    ///   transformed value.
    /// - Returns: A lazy `Sequence.CompactMap` wrapping this sequence.
    @_lifetime(copy self)
    @inlinable
    public consuming func compactMap<Output>(
        _ transform: @escaping (Element) -> Output?
    ) -> Sequence.CompactMap<Self, Output> {
        Sequence.CompactMap(_base: self, _transform: transform)
    }
}
