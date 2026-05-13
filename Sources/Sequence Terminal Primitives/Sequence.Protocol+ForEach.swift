extension Sequence.`Protocol` where Self: ~Copyable {
    /// Fluent accessor for iteration: `.forEach { body }`, `.forEach.borrowing { }`, `.forEach.consuming { }`.
    @inlinable
    public var forEach: Property<Sequence.ForEach, Self>.Inout {
        mutating _read {
            yield Property<Sequence.ForEach, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.ForEach, Self>.Inout(&self)
            yield &accessor
        }
    }
}

// MARK: - Swift.Sequence Bridging

/// Provides `@inline(always)` `forEach` for types conforming to both
/// `Sequence.Protocol` and `Swift.Sequence`.
///
/// `Swift.Sequence.forEach` is `@inlinable` but not `@inline(always)`,
/// so the closure is not guaranteed to be inlined before the CopyPropagation
/// SIL pass. This causes crashes in class deinits with `~Copyable` generic
/// parameters, where `partial_apply` captures `self` with `ForwardingConsume`
/// semantics and CopyPropagation cannot track the lifetime correctly.
///
/// This extension is more constrained than `Swift.Sequence` alone
/// (`Sequence.Protocol & Swift.Sequence` > `Swift.Sequence`), so it wins
/// overload resolution for all dual-conformers. The `@inline(always)`
/// forces closure inlining during mandatory SIL passes — before
/// CopyPropagation runs — eliminating the `partial_apply` entirely.
///
/// The Property.Inout `forEach` property remains accessible for qualified
/// variants: `instance.forEach.borrowing { }`, `instance.forEach.consuming { }`.
extension Sequence.`Protocol` where Self: Swift.Sequence {
    /// `@inline(always)` forEach for dual-conformers — wins overload resolution against `Swift.Sequence.forEach` and forces closure inlining before CopyPropagation.
    @inline(always)
    @inlinable
    public func forEach(_ body: (Element) -> Void) {
        var iterator = makeIterator()
        while let element = iterator.next() {
            body(element)
        }
    }
}
