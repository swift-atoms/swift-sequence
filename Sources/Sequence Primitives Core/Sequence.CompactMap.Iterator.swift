public import Index_Primitives

extension Sequence.CompactMap where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.CompactMap` using the Optional inline
    /// strategy.
    ///
    /// Applies the transform to each base element, skips `nil` results,
    /// and stores non-nil values in `Optional<Output>` inline storage.
    /// Same pattern as `Sequence.Map.Iterator` — see its documentation
    /// for the full Optional inline explanation.
    ///
    /// ## Suppression
    ///
    /// - `~Copyable` because the base iterator may be `~Copyable`.
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
        var _element: Output? = nil

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base.Iterator, _transform: @escaping (Base.Element) -> Output?) {
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
            while let element = _base.next() {
                if let transformed = _transform(element) {
                    _element = transformed
                    let span = unsafe Span(_unsafeStart: ptr, count: 1)
                    return unsafe _overrideLifetime(span, mutating: &self)
                }
            }
            let span = unsafe Span(_unsafeStart: ptr, count: 0)
            return unsafe _overrideLifetime(span, mutating: &self)
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
