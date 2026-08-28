extension Sequence.Map where Base: ~Copyable & ~Escapable, Base.Element: Copyable {

    @_lifetime(copy source)
    @usableFromInline
    package static func eager<Output>(
        _ source: consuming Base,
        _ transform: @escaping (Base.Element) -> Output
    ) -> Eager<Output> {
        Eager(_base: source, _transform: transform)
    }

    @_lifetime(copy source)
    @usableFromInline
    package static func compact<Output>(
        _ source: consuming Base,
        _ transform: @escaping (Base.Element) -> Output?
    ) -> Compact<Output> {
        Compact(_base: source, _transform: transform)
    }

    @_lifetime(copy source)
    @usableFromInline
    package static func flat<InnerSequence: Sequenceable>(
        _ source: consuming Base,
        _ transform: @escaping (Base.Element) -> InnerSequence
    ) -> Flat<InnerSequence>
    where InnerSequence.Element: Copyable, InnerSequence.Iterator: Escapable {
        Flat(_base: source, _transform: transform)
    }
}

extension Sequence.Map where Base: ~Copyable & ~Escapable, Base.Element: Copyable {

    @_lifetime(copy self)
    @inlinable
    public consuming func callAsFunction<Output>(
        _ transform: @escaping (Base.Element) -> Output
    ) -> Eager<Output> {
        Self.eager(consume _base, transform)
    }

    @_lifetime(copy self)
    @inlinable
    public consuming func compact<Output>(
        _ transform: @escaping (Base.Element) -> Output?
    ) -> Compact<Output> {
        Self.compact(consume _base, transform)
    }

    @_lifetime(copy self)
    @inlinable
    public consuming func flat<InnerSequence: Sequenceable>(
        _ transform: @escaping (Base.Element) -> InnerSequence
    ) -> Flat<InnerSequence>
    where InnerSequence.Element: Copyable, InnerSequence.Iterator: Escapable {
        Self.flat(consume _base, transform)
    }
}
