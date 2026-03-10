public import Index_Primitives

extension Sequence.FlatMap where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.FlatMap` with inner sequence state machine.
    ///
    /// Maintains a current inner iterator and advances through each
    /// inner sequence, transitioning to the next outer element when
    /// the current inner is exhausted.
    ///
    /// Uses the Optional inline strategy for `nextSpan`: stores the
    /// current output element in `var _element: InnerSequence.Element?`
    /// and returns a single-element `Span` pointing into it.
    ///
    /// ## In-Place Mutation
    ///
    /// The inner iterator is advanced via `_inner!.next()` rather
    /// than `if var inner = _inner`. The `if var` pattern consumes
    /// from the optional for `~Copyable` iterators, causing "cannot
    /// partially reinitialize self." In-place mutation via force-
    /// unwrap mutates `_inner` without consuming it. See experiment
    /// `flatmap-inner-iterator-state-machine` V3 (REFUTED) vs V1
    /// (CONFIRMED).
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
        public typealias Element = InnerSequence.Element

        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _transform: (Base.Element) -> InnerSequence

        @usableFromInline
        var _inner: InnerSequence.Iterator? = nil

        @usableFromInline
        var _element: InnerSequence.Element? = nil

        @_lifetime(copy _base)
        @inlinable
        init(
            _base: consuming Base.Iterator,
            _transform: @escaping (Base.Element) -> InnerSequence
        ) {
            self._base = _base
            self._transform = _transform
        }

        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Element> {
            let ptr = unsafe withUnsafeMutablePointer(to: &_element) { p in
                unsafe UnsafePointer<Element>(
                    unsafe UnsafeRawPointer(p).assumingMemoryBound(to: Element.self)
                )
            }
            guard maximumCount > .zero else {
                let span = unsafe Span(_unsafeStart: ptr, count: 0)
                return unsafe _overrideLifetime(span, mutating: &self)
            }
            while true {
                if _inner != nil {
                    if let element = _inner!.next() {
                        _element = element
                        let span = unsafe Span(_unsafeStart: ptr, count: 1)
                        return unsafe _overrideLifetime(span, mutating: &self)
                    }
                    _inner = nil
                }
                guard let baseElement = _base.next() else {
                    let span = unsafe Span(_unsafeStart: ptr, count: 0)
                    return unsafe _overrideLifetime(span, mutating: &self)
                }
                _inner = _transform(baseElement).makeIterator()
            }
        }

        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Element? {
            while true {
                if _inner != nil {
                    if let element = _inner!.next() {
                        return element
                    }
                    _inner = nil
                }
                guard let baseElement = _base.next() else {
                    return nil
                }
                _inner = _transform(baseElement).makeIterator()
            }
        }
    }
}
