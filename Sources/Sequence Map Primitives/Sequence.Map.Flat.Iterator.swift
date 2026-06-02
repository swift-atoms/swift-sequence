public import Iterator_Protocol

extension Sequence.Map.Flat where Base: ~Copyable & ~Escapable {
    /// Iterator for `Sequence.Map.Flat` with inner sequence state machine.
    ///
    /// A scalar iterator over the foundation `Iterator.`Protocol``. Maintains a
    /// current inner iterator and advances through each inner sequence,
    /// transitioning to the next outer element when the current inner is
    /// exhausted.
    public struct Iterator: ~Copyable, ~Escapable {
        @usableFromInline
        var _base: Base.Iterator

        @usableFromInline
        let _transform: (Base.Element) -> InnerSequence

        @usableFromInline
        var _inner: InnerSequence.Iterator? = nil

        @_lifetime(copy _base)
        @inlinable
        package init(
            _base: consuming Base.Iterator,
            _transform: @escaping (Base.Element) -> InnerSequence
        ) {
            self._base = _base
            self._transform = _transform
        }
    }
}

// The two iteration channels (outer base + inner sequence) are unified under a single typed
// `throws` by constraining them equal — a protocol-witness `next()` cannot carry two distinct
// failure channels (unlike a free method, the Never-overload trick is unavailable). Stage-A
// simplification (constrain-equal, not `Either`); revisitable if independent-failure flat-map is
// ever needed, at a call-site transparency cost.
extension Sequence.Map.Flat.Iterator: Iterator_Primitive.Iterator.`Protocol`
where Base: ~Copyable & ~Escapable, InnerSequence.Iterator.Failure == Base.Iterator.Failure {
    /// The element type produced by this iterator (elements of each transformed inner sequence).
    public typealias Element = InnerSequence.Element

    /// Returns the next inner element, or `nil` when all inner sequences are exhausted.
    @_lifetime(&self)
    @inlinable
    public mutating func next() throws(Base.Iterator.Failure) -> Element? {
        while true {
            if _inner != nil {
                // swift-format-ignore: NeverForceUnwrap
                if let element = try _inner!.next() {
                    return element
                }
                _inner = nil
            }
            guard let baseElement = try _base.next() else {
                return nil
            }
            _inner = _transform(baseElement).makeIterator()
        }
    }
}
