extension Sequence {
    /// Backward-compatibility typealias.
    ///
    /// Canonical name is ``Sequence/Map/Compact``.
    public typealias CompactMap<
        Base: Sequenceable & ~Copyable & ~Escapable,
        Output
    > = Sequence.Map<Base>.Compact<Output> where Base.Element: Copyable
}
