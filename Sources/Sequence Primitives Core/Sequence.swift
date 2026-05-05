/// Namespace for sequence-related types and protocols.
///
/// `Sequence` provides primitives for types that can be iterated,
/// with first-class support for both `Copyable` and `~Copyable` conformers.
///
/// ## Overview
///
/// Unlike stdlib's `Sequence` protocol which requires `Copyable`,
/// `Sequence.Protocol` supports `~Copyable` types, enabling iteration
/// over move-only containers.
///
/// ## Iteration Protocols
///
/// | Protocol | Description |
/// |----------|-------------|
/// | `Sequence.Protocol` | Iterable type (supports `~Copyable` containers) |
/// | `Sequence.Iterator.Protocol` | Iterator type (supports `~Copyable` iterators) |
/// | `Sequence.Clearable` | Adds `removeAll()` for consuming iteration |
/// | `Sequence.Drain.Protocol` | Mutating drain (container survives empty) |
/// | `Sequence.Consume.Protocol` | Consuming iteration (container destroyed) |
///
/// ## ~Copyable Element Limitation
///
/// The `Element` type implicitly requires `Copyable` per SE-0427 because
/// `IteratorProtocol.next()` returns `Element?` and `Optional` requires `Copyable`.
///
/// For `~Copyable` elements, use closure-based APIs:
///
/// | Pattern | Use Case |
/// |---------|----------|
/// | `forEach { borrowing element in }` | Borrowing iteration |
/// | `drain { consuming element in }` | Consuming iteration (container survives) |
///
/// ## Tags (Property.Inout Operations)
///
/// | Tag | Operations |
/// |-----|------------|
/// | `Sequence.ForEach` | `.forEach { }`, `.forEach.borrowing { }`, `.forEach.consuming { }` |
/// | `Sequence.Satisfies` | `.satisfies.all { }`, `.satisfies.any { }`, `.satisfies.none { }` |
/// | `Sequence.Contains` | `.contains { }` |
/// | `Sequence.First` | `.first { }` |
/// | `Sequence.Reduce` | `.reduce.into(_:) { }`, `.reduce.from(_:) { }` |
/// | `Sequence.Map` | `.map { }` |
/// | `Sequence.Filter` | `.filter { }` (requires `Element: Copyable`) |
/// | `Sequence.Count` | `.count.where { }`, `.count.all` |
/// | `Sequence.Drain` | `.drain { }` |
///
/// ## Consuming Iteration
///
/// | Type | Pattern |
/// |------|---------|
/// | `Sequence.Consume.View` | `.consume().forEach { }` |
///
/// ## Usage
///
/// 1. Conform your type to `Sequence.Protocol`:
///
/// ```swift
/// extension MyContainer: Swift.Sequence.Protocol {
///     func makeIterator() -> Array<Element>.Iterator {
///         storage.makeIterator()
///     }
/// }
/// ```
///
/// 2. Add property accessors for desired operations:
///
/// ```swift
/// extension MyContainer {
///     var forEach: Property<Sequence.ForEach, MyContainer>.Inout {
///         mutating _read {
///             yield Property<Sequence.ForEach, MyContainer>.Inout(&self)
///         }
///     }
///
///     var map: Property<Sequence.Map, MyContainer>.Inout {
///         mutating _read {
///             yield Property<Sequence.Map, MyContainer>.Inout(&self)
///         }
///     }
///     // ... other operations as needed
/// }
/// ```
///
/// 3. For span access, see `Property.Span` protocols in property-primitives.
public struct Sequence: Sendable {}
