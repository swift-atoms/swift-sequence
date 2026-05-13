extension Sequence {
    /// Lazy wrapper that transforms each element of a base sequence.
    ///
    /// Created by calling `.map { }` on a `Sequence.Protocol` conformer.
    /// Conforms to `Sequence.Protocol`, enabling further chaining.
    ///
    /// ```swift
    /// let doubled = source.map { $0 * 2 }           // Sequence.Map<Source, Int>
    /// let result = doubled.filter { $0 > 5 }.collect()
    /// ```
    ///
    /// ## Full Suppression Pattern
    ///
    /// `Sequence.Map` demonstrates the canonical pattern for creating
    /// lazy wrappers with full `~Copyable` & `~Escapable` support:
    ///
    /// 1. **Generic constraint** — `Base` suppresses both:
    ///    `Base: Sequence.Protocol & ~Copyable & ~Escapable`
    ///
    /// 2. **`@_lifetime` on init** — wrapper lifetime derived from
    ///    base: `@_lifetime(copy _base)`
    ///
    /// 3. **Conditional conformance restoration** with
    ///    cross-constraints:
    ///
    ///    ```swift
    ///    extension Sequence.Map: Copyable
    ///        where Base: Copyable & ~Escapable {}
    ///    extension Sequence.Map: Escapable
    ///        where Base: Escapable & ~Copyable {}
    ///    ```
    ///
    ///    The `& ~Escapable` cross-constraint on `Copyable` prevents
    ///    circular conformance inference.
    ///
    /// 4. **Conformance extension** with
    ///    `where Base: ~Copyable & ~Escapable`: Required even though
    ///    the struct already has those constraints. Without it, the
    ///    compiler evaluates the extension in a context where `Base`
    ///    could be `Escapable` (from conditional conformance), and
    ///    rejects `@_lifetime(copy self)` as "invalid lifetime
    ///    dependence on an Escapable value with consuming ownership".
    ///
    /// ### Constraints
    ///
    /// `Base.Element: Copyable` is required because the transform
    /// closure takes `Base.Element` by value.
    public struct Map<Base: Sequence.`Protocol` & ~Copyable & ~Escapable, Output>: ~Copyable, ~Escapable
    where Base.Element: Copyable {
        @usableFromInline
        let _base: Base

        @usableFromInline
        let _transform: (Base.Element) -> Output

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base, _transform: @escaping (Base.Element) -> Output) {
            self._base = _base
            self._transform = _transform
        }
    }
}

extension Sequence.Map: Copyable where Base: Copyable & ~Escapable {}
extension Sequence.Map: Escapable where Base: Escapable & ~Copyable {}

extension Sequence.Map: Sequence.`Protocol` where Base: ~Copyable & ~Escapable {
    /// The element type produced by this lazy sequence.
    public typealias Element = Output

    /// Creates a fresh iterator that transforms each base element by the stored closure.
    @_lifetime(copy self)
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_base: _base.makeIterator(), _transform: _transform)
    }
}
