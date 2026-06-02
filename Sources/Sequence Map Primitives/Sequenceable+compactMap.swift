extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Compact map: `source.compactMap { transform }` returns a
    /// `Sequence.Map<Self>.Compact<Output>`.
    ///
    /// Defers to the package-static `Sequence.Map.compact`.
    @_lifetime(copy self)
    @inlinable
    public consuming func compactMap<Output>(
        _ transform: @escaping (Element) -> Output?
    ) -> Sequence.Map<Self>.Compact<Output> {
        Sequence.Map<Self>.compact(consume self, transform)
    }
}
