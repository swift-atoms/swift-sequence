extension Sequence {
    /// Fluent root for map operations on `Sequence.Protocol` conformers.
    ///
    /// `Sequence.Map<Base>` is both the namespace AND the builder: it is
    /// returned by the `map` accessor on `Sequence.Protocol` and
    /// dispatches via `callAsFunction(_:)` for the eager form (invoked
    /// by trailing-closure sugar) and via `.compact(_:)` / `.flat(_:)`
    /// for the filtered / flattening forms. Nested result types live
    /// inside the same `Sequence.Map<Base>`:
    ///
    /// ```swift
    /// let doubled  = source.map { $0 * 2 }              // Sequence.Map<Source>.Eager<Int>
    /// let parsed   = source.map.compact { Int($0) }     // Sequence.Map<Source>.Compact<Int>
    /// let expanded = source.map.flat { [$0, $0 * 2] }   // Sequence.Map<Source>.Flat<[Int]>
    /// ```
    ///
    /// Bridging method shortcuts are preserved:
    ///
    /// ```swift
    /// let parsed   = source.compactMap { Int($0) }      // routes to .map.compact
    /// let expanded = source.flatMap { [$0, $0 * 2] }    // routes to .map.flat
    /// ```
    ///
    /// Backward-compatibility typealiases at the `Sequence` namespace:
    ///
    /// | Old | Canonical |
    /// |-----|-----------|
    /// | `Sequence.CompactMap<Base, Output>` | `Sequence.Map<Base>.Compact<Output>` |
    /// | `Sequence.FlatMap<Base, Inner>` | `Sequence.Map<Base>.Flat<Inner>` |
    ///
    /// ## Implementation note: `var _base` is deliberate
    ///
    /// `_base` is declared `var` rather than `let` to work around a
    /// Swift 6.3 compiler bug ("copy of noncopyable typed value. This is
    /// a compiler bug.") that fires when a `let`-bound ~Copyable stored
    /// property is moved from a `consuming self` into a sibling
    /// ~Copyable type's `consuming Base` init. Empirical reproducer +
    /// workaround:
    /// `swift-institute/Experiments/sequence-map-builder-consuming-bug/`.
    /// The field is assigned once in `package init` and consumed by
    /// `callAsFunction(_:)` / `compact(_:)` / `flat(_:)`.
    public struct Map<Base: Sequenceable & ~Copyable & ~Escapable>: ~Copyable, ~Escapable {
        @usableFromInline
        var _base: Base

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base) {
            self._base = _base
        }
    }
}

extension Sequence.Map: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.Map: Escapable where Base: Escapable & ~Copyable {}
