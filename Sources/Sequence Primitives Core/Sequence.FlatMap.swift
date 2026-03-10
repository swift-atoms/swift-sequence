extension Sequence {
    /// Lazy wrapper that transforms elements into sequences and flattens
    /// them into a single level.
    ///
    /// Created by calling `.flatMap { }` on a `Sequence.Protocol`
    /// conformer. The transform returns a sequence whose elements are
    /// concatenated.
    ///
    /// ```swift
    /// let flattened = source.flatMap { ["\($0)", "\($0 * 2)"] }
    /// let result = flattened.collect()  // ["1", "2", "2", "4", "3", "6"]
    /// ```
    ///
    /// ## Suppression Pattern
    ///
    /// Same full suppression + conditional restoration as
    /// `Sequence.Map`. See `Sequence.Map` for the canonical pattern
    /// documentation.
    ///
    /// ### Constraints
    ///
    /// `Base.Element: Copyable` is required because the transform
    /// closure takes `Base.Element` by value.
    ///
    /// `InnerSequence.Element: Copyable` is required because the
    /// flattened output elements must be returnable from the iterator.
    ///
    /// `InnerSequence.Iterator: Escapable` is required because the
    /// iterator stores `_inner: InnerSequence.Iterator?`. Without
    /// `Escapable`, `Optional<~Escapable>` is `~Escapable` and the
    /// `= nil` default has no lifetime source, causing "lifetime-
    /// dependent variable 'self' escapes its scope". See experiment
    /// `flatmap-inner-iterator-state-machine` V3 (REFUTED) vs V5
    /// (CONFIRMED).
    ///
    /// Iterator uses the Optional inline strategy on the output
    /// element, with a state machine tracking the current inner
    /// iterator via in-place mutation (`_inner!.next()`).
    public struct FlatMap<
        Base: Sequence.`Protocol` & ~Copyable & ~Escapable,
        InnerSequence: Sequence.`Protocol`
    >: ~Copyable, ~Escapable
    where Base.Element: Copyable, InnerSequence.Element: Copyable,
          InnerSequence.Iterator: Escapable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        let _transform: (Base.Element) -> InnerSequence

        @_lifetime(copy _base)
        @inlinable
        init(
            _base: consuming Base,
            _transform: @escaping (Base.Element) -> InnerSequence
        ) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.FlatMap: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.FlatMap: Escapable where Base: Escapable & ~Copyable {}

extension Sequence.FlatMap: Sequence.`Protocol` where Base: ~Copyable & ~Escapable {
    public typealias Element = InnerSequence.Element

    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _transform: _transform)
    }
}
