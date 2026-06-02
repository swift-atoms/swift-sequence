public import Either_Primitives

extension Sequenceable where Self: ~Copyable {
    // `@_disfavoredOverload`: when a type *also* conforms `Iterable`, the
    // `Iterable.forEach` borrowing floor is the canonical terminal and MUST win
    // `x.forEach { }` for dual-conformers. Disfavouring the Sequenceable forEach
    // surfaces (this accessor + the typed / fallible methods below, but NOT the
    // `@inline(always)` `Swift.Sequence` bridge, which must keep winning over
    // `Swift.Sequence.forEach`) encodes the model: the `Iterable` floor is the
    // canonical `forEach`; `Sequenceable.forEach` is the fallback for
    // `Sequenceable`-but-not-`Iterable` types. Verified debug+release, cross-module
    // `-O`, 0-`witness_method` (spike: `/tmp/set-foreach-disambig-spike`).
    /// Fluent accessor for iteration: `.forEach { body }`, `.forEach.borrowing { }`, `.forEach.consuming { }`.
    @_disfavoredOverload
    @inlinable
    public var forEach: Property<Sequence.ForEach, Self>.Inout {
        mutating _read {
            yield Property<Sequence.ForEach, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.ForEach, Self>.Inout(&self)
            yield &accessor
        }
    }
}

// MARK: - Swift.Sequence Bridging

/// Provides `@inline(always)` `forEach` for types conforming to both
/// `Sequence.Protocol` and `Swift.Sequence`.
///
/// `Swift.Sequence.forEach` is `@inlinable` but not `@inline(always)`,
/// so the closure is not guaranteed to be inlined before the CopyPropagation
/// SIL pass. This causes crashes in class deinits with `~Copyable` generic
/// parameters, where `partial_apply` captures `self` with `ForwardingConsume`
/// semantics and CopyPropagation cannot track the lifetime correctly.
///
/// This extension is more constrained than `Swift.Sequence` alone
/// (`Sequence.Protocol & Swift.Sequence` > `Swift.Sequence`), so it wins
/// overload resolution for all dual-conformers. The `@inline(always)`
/// forces closure inlining during mandatory SIL passes — before
/// CopyPropagation runs — eliminating the `partial_apply` entirely.
///
/// The Property.Inout `forEach` property remains accessible for qualified
/// variants: `instance.forEach.borrowing { }`, `instance.forEach.consuming { }`.
extension Sequenceable where Self: Swift.Sequence, Iterator.Failure == Never {
    /// `@inline(always)` forEach for dual-conformers — wins overload resolution against `Swift.Sequence.forEach` and forces closure inlining before CopyPropagation.
    @inline(always)
    @inlinable
    public func forEach(_ body: (Element) -> Void) {
        var iterator = makeIterator()
        while let element = iterator.next() {
            body(element)
        }
    }
}

// MARK: - Typed-Throws ForEach

/// Typed-throws-preserving `forEach` on `Sequence.Protocol`.
///
/// Per [API-ERR-001] every throwing surface in the institute uses typed
/// throws. The non-throwing `forEach` accessor (the `Property.Inout` form at
/// the top of this file, plus the dual-conformer bridge above) handles
/// `(Element) -> Void` closures; this extension handles
/// `(Element) throws(E) -> Void` closures, preserving the typed error `E`
/// across iteration.
///
/// ## Placement: Why on `Sequence.Protocol`, Not on the Dual-Conformer Bridge
///
/// The non-throwing dual-conformer bridge above exists for a specific
/// reason — a CopyPropagation SIL crash on `~Copyable` generic parameters
/// when `Swift.Sequence.forEach`'s `partial_apply` captures `self`. That
/// failure mode is non-throwing-closure-specific. Typed-throws iteration
/// does not exhibit the same SIL hazard; the institute owns its
/// `Sequence.Protocol` (no stdlib `forEach` to compete with), so the typed
/// variant lives directly on the protocol — broader applicability, no
/// dual-conformance requirement.
///
/// ## Composition with the Property.Inout Accessor
///
/// The Property.Inout `forEach` accessor (`var forEach: Property<Sequence.ForEach, Self>.Inout`)
/// at the top of this file remains the surface for the qualified forms
/// `.forEach.borrowing { }` and `.forEach.consuming { }`. For non-throwing
/// closures, overload resolution at `instance.forEach { body }` prefers the
/// accessor's `callAsFunction`; for closures with a typed `throws(E)`
/// clause, only this extension is viable, so it wins.
///
/// ## Constraint: `Self: Copyable, Element: Copyable`
///
/// `makeIterator()` is `consuming` on `Sequence.Protocol`. Calling it from
/// this non-consuming method on a borrowed `self` requires the compiler to
/// produce an implicit copy of `self` — which is only valid when
/// `Self: Copyable`. `Element: Copyable` is required by the closure's
/// `(Element)` parameter shape (no ownership annotation, so the closure
/// receives a copy). For `~Copyable` sequence conformers, the consuming
/// pipeline (`.collect()` + array iteration) is the substitute path.
///
/// ## Example
///
/// ```swift
/// enum Stop: Error { case requested }
///
/// var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
/// do throws(Stop) {
///     try source.forEach { element throws(Stop) in
///         if element == 3 { throw Stop.requested }
///     }
/// } catch {
///     // `error` has typed throw shape `Stop`.
/// }
/// ```
extension Sequenceable where Self: Copyable, Element: Copyable, Iterator.Failure == Never {
    // `@_disfavoredOverload`: see the accessor above — yields to the
    // `Iterable.forEach` floor for dual-conformers; this typed-throws surface is
    // the `Sequenceable`-but-not-`Iterable` fallback.
    /// Iterates the sequence, calling `body` for each element.
    ///
    /// If the closure throws an error of typed-throws type `E`, iteration
    /// stops and the error is re-thrown with the same typed shape — the
    /// typed error is not erased.
    ///
    /// `Iterator.Failure == Never` constrains this to infallible iterators; the
    /// closure carries its own typed error `E`, propagated without erasure. The
    /// fallible-iterator overload below fuses both channels via `Either`.
    ///
    /// - Parameter body: A closure called with each element. May throw `E`.
    /// - Throws: Any error of type `E` thrown by the closure.
    @_disfavoredOverload
    @inlinable
    public func forEach<E: Swift.Error>(
        _ body: (Element) throws(E) -> Void
    ) throws(E) {
        var iterator = makeIterator()
        while let element = iterator.next() {
            try body(element)
        }
    }
}

// MARK: - Fallible iterators

extension Sequenceable where Self: Copyable, Element: Copyable {
    // `@_disfavoredOverload`: see the accessor above — yields to the
    // `Iterable.forEach` floor for dual-conformers; this fallible surface is the
    // `Sequenceable`-but-not-`Iterable` fallback.
    /// Iterates a *fallible* sequence, calling `body` for each element.
    ///
    /// When `next()` itself can fail (`Iterator.Failure != Never`), the two error channels — the
    /// iterator's `Failure` and the closure's `E` — are fused, unerased, into
    /// `Either<E, Iterator.Failure>`: `.left(E)` for a closure error, `.right(Failure)` for an
    /// iterator failure. For infallible iterators the `throws(E)` overload above is more specific
    /// and wins overload resolution; this overload serves the fallible case. Mirrors
    /// `Iterable.forEach` in swift-iterator-primitives.
    ///
    /// - Parameter body: A closure called with each element. May throw `E`.
    /// - Throws: `Either<E, Iterator.Failure>` — `.left` from `body`, `.right` from the iterator.
    @_disfavoredOverload
    @inlinable
    public func forEach<E: Swift.Error>(
        _ body: (Element) throws(E) -> Void
    ) throws(Either<E, Iterator.Failure>) {
        var iterator = makeIterator()
        while true {
            let step: Element?
            do {
                step = try iterator.next()
            } catch {
                throw Either.right(error)
            }
            guard let element = step else { return }
            do {
                try body(element)
            } catch {
                throw Either.left(error)
            }
        }
    }
}

// The consuming drain terminal lives in `Sequenceable+Consume.swift` as `consume(_:)`,
// NOT here — `forEach` stays purely the borrow terminal (no consuming overload), so there
// is no borrow-vs-consume asymmetry on `forEach`. (The `@_disfavoredOverload` on the
// Sequenceable forEach surfaces above is a *cross-protocol* precedence tiebreaker that
// yields to the `Iterable.forEach` floor for dual-conformers — NOT a borrow-vs-consume
// disambiguator within `Sequenceable`.)
