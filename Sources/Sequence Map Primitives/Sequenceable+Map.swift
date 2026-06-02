extension Sequenceable where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Eager map: `source.map { transform }` returns a
    /// `Sequence.Map<Self>.Eager<Output>`.
    ///
    /// Defers to the package-static `Sequence.Map.eager` so the
    /// `~Copyable` / `~Escapable` consuming-parameter shape is accepted
    /// by the Swift move-checker.
    @_lifetime(copy self)
    @inlinable
    public consuming func map<Output>(
        _ transform: @escaping (Element) -> Output
    ) -> Sequence.Map<Self>.Eager<Output> {
        Sequence.Map<Self>.eager(consume self, transform)
    }
}

// MARK: - Fluent property accessor (Copyable Self only)
//
// `source.map.compact { ... }` requires `.map` to be a property
// returning the Builder. Swift's move-checker rejects this for
// `~Copyable` Self at direct user call sites (per the parser-primitives
// owned-consuming-get-on-protocol-extension experiment, 2026-05-14).
// For Copyable Self — the common case (`Array<Int>`, etc.) — the
// implicit copy bypasses the move-checker restriction.

extension Sequenceable where Self: Copyable {
    /// Fluent map root for Copyable sequences:
    /// `.map { }`, `.map.compact { }`, `.map.flat { }`.
    @inlinable
    public var map: Sequence.Map<Self> {
        consuming get { Sequence.Map(_base: self) }
    }
}
