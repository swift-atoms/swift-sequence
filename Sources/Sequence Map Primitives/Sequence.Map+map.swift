// MARK: - Static implementations (canonical, package-scoped)
//
// `Sequence.Map.eager`, `.compact`, `.flat` are the canonical
// implementations. Every other Map-shaped API on `Sequence.Protocol`
// and `Sequence.Map` defers to one of these statics — they are
// "consuming-parameter wrappers" in the sense of the parser-primitives
// owned-consuming-get experiment, which the Swift move-checker accepts
// uniformly for ~Copyable/~Escapable Base.

extension Sequence.Map where Base: ~Copyable & ~Escapable, Base.Element: Copyable {
    /// Eager-map construction (static, package-scoped).
    ///
    /// Defers from `Sequence.Protocol.map(_:)` and the
    /// `Sequence.Map.callAsFunction` instance method.
    @_lifetime(copy source)
    @usableFromInline
    package static func eager<Output>(
        _ source: consuming Base,
        _ transform: @escaping (Base.Element) -> Output
    ) -> Eager<Output> {
        Eager(_base: source, _transform: transform)
    }

    /// Compact-map construction (static, package-scoped).
    ///
    /// Defers from `Sequence.Protocol.compactMap(_:)` and
    /// `Sequence.Map.compact(_:)`.
    @_lifetime(copy source)
    @usableFromInline
    package static func compact<Output>(
        _ source: consuming Base,
        _ transform: @escaping (Base.Element) -> Output?
    ) -> Compact<Output> {
        Compact(_base: source, _transform: transform)
    }

    /// Flat-map construction (static, package-scoped).
    ///
    /// Defers from `Sequence.Protocol.flatMap(_:)` and
    /// `Sequence.Map.flat(_:)`.
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

// MARK: - Instance methods on Sequence.Map (the Builder)

extension Sequence.Map where Base: ~Copyable & ~Escapable, Base.Element: Copyable {
    /// Eager map via `Sequence.Map(consume source) { transform }`.
    ///
    /// Trailing-closure sugar calls this through `callAsFunction`.
    /// Defers to `Sequence.Map.eager`.
    @_lifetime(copy self)
    @inlinable
    public consuming func callAsFunction<Output>(
        _ transform: @escaping (Base.Element) -> Output
    ) -> Eager<Output> {
        Self.eager(consume _base, transform)
    }

    /// Compact map via `.compact { transform }` on a `Sequence.Map`.
    ///
    /// Defers to `Sequence.Map.compact` static.
    @_lifetime(copy self)
    @inlinable
    public consuming func compact<Output>(
        _ transform: @escaping (Base.Element) -> Output?
    ) -> Compact<Output> {
        Self.compact(consume _base, transform)
    }

    /// Flat map via `.flat { transform }` on a `Sequence.Map`.
    ///
    /// Defers to `Sequence.Map.flat` static.
    @_lifetime(copy self)
    @inlinable
    public consuming func flat<InnerSequence: Sequenceable>(
        _ transform: @escaping (Base.Element) -> InnerSequence
    ) -> Flat<InnerSequence>
    where InnerSequence.Element: Copyable, InnerSequence.Iterator: Escapable {
        Self.flat(consume _base, transform)
    }
}
