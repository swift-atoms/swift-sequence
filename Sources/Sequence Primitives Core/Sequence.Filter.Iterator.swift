public import Index_Primitives

extension Sequence.Filter where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Filter` using the heap buffer strategy.
    ///
    /// Scans the base iterator via `next()`, stores matching elements
    /// in a heap-allocated buffer, and returns single-element spans.
    /// Same pattern as `Sequence.Map.Iterator` — see its documentation
    /// for the full heap buffer strategy explanation.
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
        public typealias Element = Base.Element

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @usableFromInline
        let _mutableBuffer: UnsafeMutablePointer<Base.Element>

        @usableFromInline
        var _bufferPtr: UnsafePointer<Base.Element>

        @usableFromInline
        var _bufferInitialized: Bool

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
            let buf = unsafe UnsafeMutablePointer<Base.Element>.allocate(capacity: 1)
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
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Base.Element> {
            guard maximumCount > .zero else {
                return unsafe Span(_unsafeStart: _bufferPtr, count: 0)
            }
            while let candidate = _base.next() {
                if _predicate(candidate) {
                    if _bufferInitialized {
                        unsafe _mutableBuffer.deinitialize(count: 1)
                    }
                    unsafe _mutableBuffer.initialize(to: candidate)
                    _bufferInitialized = true
                    let span = unsafe Span(_unsafeStart: _bufferPtr, count: 1)
                    return unsafe _overrideLifetime(span, mutating: &self)
                }
            }
            return unsafe Span(_unsafeStart: _bufferPtr, count: 0)
        }

        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Base.Element? {
            while let element = _base.next() {
                if _predicate(element) {
                    return element
                }
            }
            return nil
        }
    }
}
