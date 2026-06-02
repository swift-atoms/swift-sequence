public import Either_Primitives

// MARK: - Consuming drain terminal

/// The consuming-iteration terminal on `Sequenceable` — the fold target that
/// replaces the former type-erased consuming-drain view/protocol.
///
/// `consume` is a DISTINCT verb (not a `forEach` overload): `forEach` is purely the
/// borrowing/non-destructive terminal, `consume` is the single-pass destructive one.
/// Keeping them distinct avoids the borrow-vs-consume overload ambiguity (and the
/// `@_disfavoredOverload` asymmetry it would otherwise require) — and stays clear of
/// `Sequence.Drain.\`Protocol\`` (a mutating clear-and-reuse drain, a different concept).
///
/// `makeIterator()` is `consuming`, so a `~Copyable` sequence that cannot be
/// implicit-copied drains itself by *consuming* `self` into the iterator and running it
/// to exhaustion. Each element is handed to `body` as `consuming` (owned move-out); the
/// `~Copyable` iterator's `deinit` cleans up any remaining elements on early exit —
/// equivalent to the former drain view's `State.deinit`.
///
/// Call-site migration from the deleted consuming-drain view:
/// `x.consume().forEach { e in … }` → `x.consume { e in … }`;
/// the `while let e = view.next()` pull-form → `var it = x.makeIterator(); while let e = it.next()`.
///
/// ## Constraint: `Element: Escapable`
///
/// This is an *extraction* terminal (like `collect` / `first`): `next()` is
/// `@_lifetime(&self)`, so a returned-by-value element constrains `Element: Escapable`.
/// `~Escapable` elements iterate via the borrowing surface (`Sequence.Borrowing.Protocol`).
extension Sequenceable where Self: ~Copyable, Element: Escapable, Iterator.Failure == Never {
    /// Consumes the sequence, calling `body` with each owned element in order.
    ///
    /// - Parameter body: a closure called with each owned element; may throw `E`.
    /// - Throws: any error of type `E` thrown by `body`.
    @inlinable
    public consuming func consume<E: Swift.Error>(
        _ body: (consuming Element) throws(E) -> Void
    ) throws(E) {
        var iterator = makeIterator()
        while let element = iterator.next() {
            try body(element)
        }
    }
}

// MARK: - Fallible iterators

extension Sequenceable where Self: ~Copyable, Element: Escapable {
    /// Consumes a *fallible* sequence, calling `body` with each owned element.
    ///
    /// When `next()` itself can fail (`Iterator.Failure != Never`), the closure error `E`
    /// and the iterator's `Failure` are fused, unerased, into `Either<E, Iterator.Failure>`:
    /// `.left(E)` for a closure error, `.right(Failure)` for an iterator failure. For
    /// infallible iterators the `throws(E)` overload above is more specific and wins
    /// resolution. Mirrors `Iterable.forEach`'s fallible overload ([API-ERR-001]).
    ///
    /// - Parameter body: a closure called with each owned element; may throw `E`.
    /// - Throws: `Either<E, Iterator.Failure>` — `.left` from `body`, `.right` from the iterator.
    @inlinable
    public consuming func consume<E: Swift.Error>(
        _ body: (consuming Element) throws(E) -> Void
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
