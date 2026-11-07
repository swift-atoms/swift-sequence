public struct Sequence: Sendable {}

extension Sequence {

    public typealias CompactMap<
        Base: Sequenceable & ~Copyable & ~Escapable,
        Output
    > = Sequence.Map<Base>.Compact<Output> where Base.Element: Copyable
}

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
