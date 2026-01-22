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
/// ## Type Family
///
/// | Type | Purpose |
/// |------|---------|
/// | `Sequence.Protocol` | Protocol for iterable types (supports `~Copyable`) |
/// | `Sequence.ForEach` | Tag for `.forEach` property extensions |
///
/// ## Usage
///
/// Conform your type to `Sequence.Protocol`:
///
/// ```swift
/// extension MyContainer: Sequence.Protocol {
///     func makeIterator() -> Array<Element>.Iterator {
///         storage.makeIterator()
///     }
/// }
/// ```
///
/// Then add the `.forEach` property to get borrowing and consuming iteration:
///
/// ```swift
/// var forEach: Property<Sequence.ForEach, MyContainer>.View { ... }
/// ```
public struct Sequence: Sendable {}
