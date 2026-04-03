public import Index_Primitives

extension Sequence.Map where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Map` that transforms elements using
    /// `Optional<Output>` as inline storage.
    ///
    /// Uses the **Optional inline** strategy: `var _element: Output? = nil`
    /// as inline deferred-initialization storage. The Optional payload is
    /// at byte offset 0 (ABI guarantee for single-payload enums),
    /// enabling `withUnsafeMutablePointer` + `assumingMemoryBound` to
    /// produce a valid `Span<Output>`. Zero heap allocation.
    ///
    /// ## Suppression
    ///
    /// - `~Copyable` because the base iterator may be `~Copyable`.
    /// - `~Escapable` because its lifetime is derived from the base
    ///   iterator (via `@_lifetime(copy _base)`).
    ///
    /// ## Extension `where` Clause
    ///
    /// The `where Base: ~Copyable & ~Escapable` on this extension is
    /// required. Nested types in separate extension files (per
    /// one-type-per-file convention) must use the same `where` clause
    /// as the conformance extension, or the compiler cannot resolve
    /// the type across extensions.
    ///
    /// ## `_overrideLifetime`
    ///
    /// `_overrideLifetime(span, mutating: &self)` chains the `Span`'s
    /// lifetime to the iterator, satisfying the `@_lifetime(&self)`
    /// return requirement of `nextSpan`.
    ///
    /// ## `next()` Override
    ///
    /// Overrides the default `next()` for performance. The default
    /// calls `nextSpan(maximumCount: 1)` which constructs a `Span`
    /// with overhead. This override returns the transformed value
    /// directly. `@_lifetime(self: immortal)` because it returns an
    /// owned `Copyable` value, not a borrowed span.
    public struct Iterator: ~Copyable, ~Escapable, Sequence.Iterator.`Protocol` {
        public typealias Element = Output

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _transform: (Base.Element) -> Output

        @usableFromInline
        var _element: Output? = nil

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base.Iterator, _transform: @escaping (Base.Element) -> Output) {
            self._base = _base
            self._transform = _transform
        }

        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Output> {
            let ptr = unsafe withUnsafeMutablePointer(to: &_element) { p in
                unsafe UnsafePointer<Output>(
                    unsafe UnsafeRawPointer(p).assumingMemoryBound(to: Output.self)
                )
            }
            guard maximumCount > .zero else {
                let span = unsafe Span(_unsafeStart: ptr, count: 0)
                return unsafe _overrideLifetime(span, mutating: &self)
            }
            guard let element = _base.next() else {
                let span = unsafe Span(_unsafeStart: ptr, count: 0)
                return unsafe _overrideLifetime(span, mutating: &self)
            }
            _element = _transform(element)
            let span = unsafe Span(_unsafeStart: ptr, count: 1)
            return unsafe _overrideLifetime(span, mutating: &self)
        }

        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Output? {
            guard let element = _base.next() else { return nil }
            return _transform(element)
        }
    }
}
