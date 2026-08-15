/// `var first` for `Sequenceable` conformers (stdlib interop).
///
/// `Swift.Sequence` provides `func first(where:)` but not `var first: Element?`
/// (that property lives on `Collection`). This supplies the property so that
/// `sequence.first` resolves to a property access rather than a `first(where:)`
/// method reference.
///
/// (The `Swift.Sequence` conformance bridge itself is the deferred ecosystem-wide
/// axis — one generic `where Element: Copyable` bridge vended once — not a per-type
/// re-add; see `set-ordered-capability-composition.md` §2.8 / §3.)
extension Sequenceable
where Self: Copyable, Element: Copyable & Escapable, Iterator.Failure == Never {
    /// The first element of the sequence, or `nil` if empty.
    ///
    /// Constrained to infallible iterators (`Iterator.Failure == Never`) so the
    /// property accessor stays non-throwing.
    @inlinable
    public var first: Element? {
        var iterator = makeIterator()
        return iterator.next()
    }
}
