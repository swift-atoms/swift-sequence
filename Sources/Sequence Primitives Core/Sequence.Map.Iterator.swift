public import Index_Primitives

extension Sequence.Map where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Map` that transforms elements via a heap
    /// buffer.
    ///
    /// Uses the **heap buffer** iterator strategy: a single
    /// heap-allocated element buffer for the transformed output. One
    /// allocation per iterator lifetime. The `deinit` ensures
    /// deterministic cleanup of both the stored element and the
    /// allocation.
    ///
    /// ## Suppression
    ///
    /// - `~Copyable` because it has a `deinit` (manages heap
    ///   allocation).
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
        let _mutableBuffer: UnsafeMutablePointer<Output>

        @usableFromInline
        var _bufferPtr: UnsafePointer<Output>

        @usableFromInline
        var _bufferInitialized: Bool

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base.Iterator, _transform: @escaping (Base.Element) -> Output) {
            self._base = _base
            self._transform = _transform
            let buf = unsafe UnsafeMutablePointer<Output>.allocate(capacity: 1)
            self._mutableBuffer = buf
            self._bufferPtr = unsafe UnsafePointer(buf)
            self._bufferInitialized = false
        }

        deinit {
            if _bufferInitialized {
                _mutableBuffer.deinitialize(count: 1)
            }
            _mutableBuffer.deallocate()
        }

        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Output> {
            guard maximumCount > .zero else {
                return unsafe Span(_unsafeStart: _bufferPtr, count: 0)
            }
            guard let element = _base.next() else {
                return unsafe Span(_unsafeStart: _bufferPtr, count: 0)
            }
            let transformed = _transform(element)
            if _bufferInitialized {
                unsafe _mutableBuffer.deinitialize(count: 1)
            }
            unsafe _mutableBuffer.initialize(to: transformed)
            _bufferInitialized = true
            let span = unsafe Span(_unsafeStart: _bufferPtr, count: 1)
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
