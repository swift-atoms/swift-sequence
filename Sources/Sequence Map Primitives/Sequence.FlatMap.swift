extension Sequence {
    /// Backward-compatibility typealias.
    ///
    /// Canonical name is ``Sequence/Map/Flat``.
    public typealias FlatMap<
        Base: Sequenceable & ~Copyable & ~Escapable,
        InnerSequence: Sequenceable
    > = Sequence.Map<Base>.Flat<InnerSequence>
    where
        Base.Element: Copyable,
        InnerSequence.Element: Copyable,
        InnerSequence.Iterator: Escapable
}
