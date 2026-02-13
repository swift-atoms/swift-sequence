/// Bridge to `Swift.Sequence` for `Copyable` conformers.
///
/// Types conforming to `Sequence.Protocol` that are `Copyable` can also
/// conform to `Swift.Sequence` with no additional implementation:
///
/// ```swift
/// struct MyContainer: Sequence.`Protocol`, Swift.Sequence {
///     func makeIterator() -> Array<Int>.Iterator { ... }
///     // Swift.Sequence satisfied automatically
/// }
/// ```
///
/// ## Why This Works
///
/// `Sequence.Protocol` requires `Iterator: Sequence.Iterator.Protocol`,
/// while `Swift.Sequence` requires `Iterator: IteratorProtocol`.
/// Types that conform their iterator to both `Sequence.Iterator.Protocol`
/// and `IteratorProtocol` satisfy both protocol requirements, enabling
/// the bridge for `Copyable` conformers.
///
/// ## Usage
///
/// ```swift
/// // 1. Define your type with Sequence.Protocol
/// struct Numbers: Sequence.`Protocol` {
///     let values: [Int]
///     func makeIterator() -> Array<Int>.Iterator {
///         values.makeIterator()
///     }
/// }
///
/// // 2. Add Swift.Sequence conformance (no implementation needed)
/// extension Numbers: Swift.Sequence {}
///
/// // 3. Now works with for-in and stdlib algorithms
/// for n in Numbers(values: [1, 2, 3]) { print(n) }
/// ```
extension Sequence.`Protocol` where Self: Copyable {
    /// Default `underestimatedCount` for stdlib compatibility.
    ///
    /// Returns 0 as a safe default. Types with known counts should override.
    @inlinable
    public var underestimatedCount: Int { 0 }

    /// The first element of the sequence, or `nil` if empty.
    ///
    /// `Swift.Sequence` provides `func first(where:)` but does NOT provide
    /// `var first: Element?` — that property lives on `Collection`.
    /// Without this, `sequence.first` resolves to the `first(where:)`
    /// method reference, not a property access.
    @inlinable
    public var first: Element? {
        var iterator = makeIterator()
        return iterator.next()
    }
}
