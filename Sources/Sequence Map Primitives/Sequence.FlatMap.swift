extension Sequence {

    public typealias FlatMap<
        Base: Sequenceable & ~Copyable & ~Escapable,
        InnerSequence: Sequenceable<InnerSequence.Element>
    > = Sequence.Map<Base>.Flat<InnerSequence>
    where
        Base.Element: Copyable,
        InnerSequence.Element: Copyable & Escapable,
        InnerSequence.Iterator: Escapable
}
