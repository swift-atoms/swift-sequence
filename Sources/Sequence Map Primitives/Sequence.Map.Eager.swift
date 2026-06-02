extension Sequence.Map where Base: ~Copyable & ~Escapable, Base.Element: Copyable {
    // `Output` stays Escapable (a World boundary, not a limitation): a `map` lending a
    // ~Escapable borrowed view would have to vend a borrow handle (`Ownership.Borrow<Output>`)
    // tied to `self` — keep-and-lend, which is categorically World B (the consume/borrow
    // dichotomy). World-A Map is give-away/single-pass; the borrowed-view transform is a
    // separate borrow-side concern, not here.
    /// Lazy wrapper that transforms each element of a base sequence.
    ///
    /// Created via `source.map { transform }`. Conforms to
    /// `Sequence.Protocol`, enabling further chaining.
    ///
    /// ```swift
    /// let doubled = source.map { $0 * 2 }     // Sequence.Map<Source>.Eager<Int>
    /// let result  = doubled.filter { $0 > 5 }.collect()
    /// ```
    public struct Eager<Output>: ~Copyable, ~Escapable {
        @usableFromInline
        var _base: Base  // var per the [compiler-bug workaround] noted on Sequence.Map.

        @usableFromInline
        let _transform: (Base.Element) -> Output

        @_lifetime(copy _base)
        @inlinable
        package init(_base: consuming Base, _transform: @escaping (Base.Element) -> Output) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map.Eager: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.Map.Eager: Escapable where Base: Escapable & ~Copyable {}

extension Sequence.Map.Eager: Sequenceable where Base: ~Copyable & ~Escapable {
    /// The element type produced by this sequence (the transform's output).
    public typealias Element = Output

    /// Returns the iterator that yields each transformed element of the base.
    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _transform: _transform)
    }
}
