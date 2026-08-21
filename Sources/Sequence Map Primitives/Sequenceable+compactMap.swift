extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {

    @_lifetime(copy self)
    @inlinable
    public consuming func compactMap<Output>(
        _ transform: @escaping (Element) -> Output?
    ) -> Sequence.Map<Self>.Compact<Output> {
        Sequence.Map<Self>.compact(consume self, transform)
    }
}
