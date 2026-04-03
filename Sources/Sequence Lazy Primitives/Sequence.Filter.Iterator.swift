public import Index_Primitives

extension Sequence.Filter where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Filter` using the Optional inline strategy.
    ///
    /// Scans the base iterator via `next()`, stores matching elements
    /// in `Optional<Base.Element>` inline storage, and returns
    /// single-element spans. Same pattern as `Sequence.Map.Iterator` —
    /// see its documentation for the full Optional inline explanation.
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
        public typealias Element = Base.Element

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _predicate: (Base.Element) -> Bool

        @usableFromInline
        var _element: Base.Element? = nil

        @_lifetime(copy _base)
        @inlinable
        init(_base: consuming Base.Iterator, _predicate: @escaping (Base.Element) -> Bool) {
            self._base = _base
            self._predicate = _predicate
        }

        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Base.Element> {
            let ptr = unsafe withUnsafeMutablePointer(to: &_element) { p in
                unsafe UnsafePointer<Base.Element>(
                    unsafe UnsafeRawPointer(p).assumingMemoryBound(to: Base.Element.self)
                )
            }
            guard maximumCount > .zero else {
                let span = unsafe Span(_unsafeStart: ptr, count: 0)
                return unsafe _overrideLifetime(span, mutating: &self)
            }
            while let candidate = _base.next() {
                if _predicate(candidate) {
                    _element = candidate
                    let span = unsafe Span(_unsafeStart: ptr, count: 1)
                    return unsafe _overrideLifetime(span, mutating: &self)
                }
            }
            let span = unsafe Span(_unsafeStart: ptr, count: 0)
            return unsafe _overrideLifetime(span, mutating: &self)
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
