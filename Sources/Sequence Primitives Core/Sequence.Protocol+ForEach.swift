extension Sequence.`Protocol` where Self: ~Copyable {
    @inlinable
    public var forEach: Property<Sequence.ForEach, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.ForEach, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Sequence.ForEach, Self>.View(&self)
            yield &view
        }
    }
}

// MARK: - Swift.Sequence Bridging

/// Provides `@inline(__always)` `forEach` for types conforming to both
/// `Sequence.Protocol` and `Swift.Sequence`.
///
/// `Swift.Sequence.forEach` is `@inlinable` but not `@inline(__always)`,
/// so the closure is not guaranteed to be inlined before the CopyPropagation
/// SIL pass. This causes crashes in class deinits with `~Copyable` generic
/// parameters, where `partial_apply` captures `self` with `ForwardingConsume`
/// semantics and CopyPropagation cannot track the lifetime correctly.
///
/// This extension is more constrained than `Swift.Sequence` alone
/// (`Sequence.Protocol & Swift.Sequence` > `Swift.Sequence`), so it wins
/// overload resolution for all dual-conformers. The `@inline(__always)`
/// forces closure inlining during mandatory SIL passes — before
/// CopyPropagation runs — eliminating the `partial_apply` entirely.
///
/// The Property.View `forEach` property remains accessible for qualified
/// variants: `instance.forEach.borrowing { }`, `instance.forEach.consuming { }`.
extension Sequence.`Protocol` where Self: Swift.Sequence {
    @inline(__always)
    @inlinable
    public func forEach(_ body: (Element) -> Void) {
        var iterator = makeIterator()
        while let element = iterator.next() {
            body(element)
        }
    }
}
