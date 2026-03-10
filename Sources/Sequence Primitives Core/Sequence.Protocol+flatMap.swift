extension Sequence.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Returns a lazy sequence that transforms elements into sequences
    /// and flattens them into a single level.
    ///
    /// ```swift
    /// let source = Source([1, 2, 3])
    /// let result = source.flatMap { n in
    ///     Source(Array(repeating: n, count: n))
    /// }.collect()
    /// // [1, 2, 2, 3, 3, 3]
    /// ```
    ///
    /// `@_lifetime(copy self)` — the returned wrapper's lifetime is
    /// derived from the consumed `self`. Available on all conformers
    /// because `~Copyable` & `~Escapable` suppression is permissive.
    ///
    /// `Element: Copyable` is required because the transform closure
    /// takes elements by value.
    ///
    /// - Parameter transform: A closure that returns a sequence of
    ///   values for each element.
    /// - Returns: A lazy `Sequence.FlatMap` wrapping this sequence.
    @_lifetime(copy self)
    @inlinable
    public consuming func flatMap<InnerSequence: Sequence.`Protocol`>(
        _ transform: @escaping (Element) -> InnerSequence
    ) -> Sequence.FlatMap<Self, InnerSequence>
    where InnerSequence.Element: Copyable, InnerSequence.Iterator: Escapable {
        Sequence.FlatMap(_base: self, _transform: transform)
    }
}
