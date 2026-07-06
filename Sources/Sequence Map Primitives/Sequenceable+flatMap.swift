extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Flat map: `source.flatMap { transform }` returns a
    /// `Sequence.Map<Self>.Flat<InnerSequence>`.
    ///
    /// Defers to the package-static `Sequence.Map.flat`.
    @_lifetime(copy self)
    @inlinable
    // Generic constraint conformance (InnerSequence: Sequenceable), not identity —
    // Self would wrongly force InnerSequence == Self (cf. svg 60e00fd precedent).
    // swiftlint:disable:next prefer_self_in_static_references
    public consuming func flatMap<InnerSequence: Sequenceable>(
        _ transform: @escaping (Element) -> InnerSequence
    ) -> Sequence.Map<Self>.Flat<InnerSequence>
    where InnerSequence.Element: Copyable, InnerSequence.Iterator: Escapable {
        Sequence.Map<Self>.flat(consume self, transform)
    }
}
