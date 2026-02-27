public import Index_Primitives

extension Sequence.CompactMap where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.CompactMap` using the heap buffer
    /// strategy.
    ///
    /// Applies the transform to each base element, skips `nil` results,
    /// and stores non-nil values in a heap-allocated buffer. Same
    /// pattern as `Sequence.Map.Iterator` — see its documentation for
    /// the full heap buffer strategy explanation.
    ///
    /// ## Suppression
    ///
    /// - `~Copyable` because it has a `deinit` (manages heap
    ///   allocation).
    /// - `~Escapable` because its lifetime is derived from the base
    ///   iterator.
    ///
    /// ## Extension `where` Clause
    ///
    /// The `where Base: ~Copyable & ~Escapable` on this extension is
    /// required — same as `Map.Iterator`.
    public struct Iterator: ~Copyable, ~Escapable, Sequence.Iterator.`Protocol` {
        public typealias Element = Output

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _transform: (Base.Element) -> Output?

        @usableFromInline
        let _mutableBuffer: UnsafeMutablePointer<Output>

        @usableFromInline
        var _bufferPtr: UnsafePointer<Output>

        @usableFromInline
        var _bufferInitialized: Bool

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base.Iterator, _transform: @escaping (Base.Element) -> Output?) {
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
            while let element = _base.next() {
                if let transformed = _transform(element) {
                    if _bufferInitialized {
                        unsafe _mutableBuffer.deinitialize(count: 1)
                    }
                    unsafe _mutableBuffer.initialize(to: transformed)
                    _bufferInitialized = true
                    let span = unsafe Span(_unsafeStart: _bufferPtr, count: 1)
                    return unsafe _overrideLifetime(span, mutating: &self)
                }
            }
            return unsafe Span(_unsafeStart: _bufferPtr, count: 0)
        }

        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Output? {
            while let element = _base.next() {
                if let transformed = _transform(element) {
                    return transformed
                }
            }
            return nil
        }
    }
}
