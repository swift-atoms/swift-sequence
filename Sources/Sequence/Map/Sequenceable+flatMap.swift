extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {

    @_lifetime(copy self)
    @inlinable

    public consuming func flatMap<InnerSequence: Sequenceable>(
        _ transform: @escaping (Element) -> InnerSequence
    ) -> Sequence.Map<Self>.Flat<InnerSequence>
    where InnerSequence.Element: Copyable, InnerSequence.Iterator: Escapable {
        Sequence.Map<Self>.flat(consume self, transform)
    }
}
