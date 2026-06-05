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
/// | `Sequence.Drain.Protocol` | Mutating drain (container survives empty) |
///
/// ## ~Copyable Elements
///
/// `Sequence.Protocol.Element` suppresses `Copyable`, supporting
/// move-only types (file descriptors, unique handles). `~Escapable`
/// elements are BLOCKED until `Swift.Span<Element>` accepts
/// `Element: ~Escapable` upstream (Swift 6.3.1 requires
/// `Element: Escapable`).
///
/// The default `next() -> Element?` extension on
/// ``Sequence/Iterator-swift.enum/Protocol-swift.protocol`` is gated on
/// `Element: Copyable` because `Optional<Element>` requires `Copyable`.
/// For `~Copyable` elements, iteration goes through `nextSpan` directly
/// or via closure-based APIs:
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
/// | `Sequence.Hint` | `.hint.count` (cheap under-estimate; default `.zero`) |
/// | `Sequence.Drain` | `.drain { }` |
///
/// Non-tag terminals:
///
/// | Accessor | Description |
/// |----------|-------------|
/// | `.count` | Eager total count (`Cardinal`, consuming) |
/// | `.count(where:)` | Filtered count (`Cardinal`, consuming) |
///
/// ## Consuming Iteration
///
/// | Terminal | Pattern |
/// |----------|---------|
/// | `Sequenceable.consume(_:)` | `.consume { element in … }` |
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
