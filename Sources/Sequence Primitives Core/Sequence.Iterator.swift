extension Sequence {
    /// Namespace for iterator-related types and protocols.
    ///
    /// ## Overview
    ///
    /// `Sequence.Iterator` provides protocols for iterator types that support
    /// `~Copyable` iterators while documenting the current language limitations
    /// around `~Copyable` elements.
    ///
    /// ## Protocol Hierarchy
    ///
    /// ```
    /// Swift.IteratorProtocol    ← stdlib, iterator must be Copyable
    ///       ↓
    /// Sequence.Iterator.Protocol ← iterator can be ~Copyable
    /// ```
    ///
    /// ## Element Type Limitation
    ///
    /// The `Element` associated type implicitly requires `Copyable` because:
    /// 1. `next() -> Element?` returns `Optional<Element>`
    /// 2. `Optional` requires its wrapped type to be `Copyable`
    ///
    /// This is a **language limitation**, not a design choice. See
    /// ``Sequence/Iterator/Protocol`` for future direction.
    ///
    /// ## ~Copyable Element Iteration
    ///
    /// For `~Copyable` elements, use closure-based APIs instead:
    ///
    /// | Pattern | Use Case |
    /// |---------|----------|
    /// | `forEach { borrowing element in }` | Borrowing iteration |
    /// | `drain { consuming element in }` | Consuming iteration (container survives) |
    /// | `consume().forEach { }` | Consuming iteration (container destroyed) |
    public enum Iterator {}
}
