extension Sequence {

    public typealias CompactMap<
        Base: Sequenceable & ~Copyable & ~Escapable,
        Output
    > = Sequence.Map<Base>.Compact<Output> where Base.Element: Copyable
}
