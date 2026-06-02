/// A type that produces elements through *consuming* iteration — the single-pass
/// attachable of the iteration family.
///
/// `Sequenceable` is the foundation of the lazy pipeline. Its sole requirement —
/// `consuming func makeIterator()` — enables chaining:
///
/// ```swift
/// let result = source
///     .map { $0 * 2 }
///     .filter { $0 > 5 }
///     .collect()  // [Element]
/// ```
///
/// Each operation consumes the previous sequence and stores it inside the wrapper.
/// The final `.collect()` consumes the chain and materializes it into an `Array`.
///
/// ## Relationship to `Iterable` — two orthogonal siblings
///
/// `Sequenceable` is the *single-pass* (consuming) attachable; its sibling `Iterable`
/// (in `swift-iterator-primitives`) is the *multipass* (borrowing) attachable. They are
/// **orthogonal capabilities, not a refinement chain** — the same orthogonality that
/// separates `Sequence` from `Collection`. Both vend an `Iterator.`Protocol`` and reuse
/// the *one* foundation iterator protocol; there is no edge making a `Sequenceable`
/// automatically `Iterable`. A single type may conform to both, but not for free: both
/// declare `associatedtype Iterator`, which Swift unifies, so a dual conformer splits the
/// bindings with `@_implements` (the associated-type-trap escape hatch).
///
/// ## Conforming to `Sequenceable`
///
/// Provide `makeIterator()` returning an `Iterator.`Protocol`` conformer:
///
/// ```swift
/// struct Source<Element: Sendable>: Sequenceable, Sendable {
///     let _elements: [Element]
///     consuming func makeIterator() -> Iterator { Iterator(_elements) }
/// }
/// ```
///
/// See `Sequence.Fixture.Source` in the test support module for the minimal
/// conformer reference.
///
/// ### Why `consuming`
///
/// Consuming ownership enables lazy composition: each `.map { }`, `.filter { }`, or
/// `.drop(first:)` consumes the source and stores it inside the lazy wrapper, avoiding
/// copies and allowing the whole pipeline to be consumed by a terminal. For **Copyable**
/// conformers (the common case) consuming a `let` binding makes an implicit copy, so the
/// original binding remains valid — no behavioral change for the caller. Single-pass
/// `~Copyable` sources (one-shot generators, network streams) are admitted too — the
/// reason `Sequenceable` is distinct from the multipass `Iterable`.
///
/// ### `@_lifetime(copy self)`
///
/// The vended `Iterator` is `~Escapable`, so its lifetime must be tied to `self` — hence
/// `@_lifetime(copy self)`. The annotation is required precisely because the yield is
/// `~Escapable`; a `next()` / `makeIterator()` yielding an *Escapable* value omits it (the
/// compiler rejects `@_lifetime` on an Escapable result).
///
/// ## Two-tier iteration model
///
/// | Protocol | Ownership | Use Case |
/// |----------|-----------|----------|
/// | `Sequenceable` | `consuming` | Lazy chains, terminal operations |
/// | `Sequence.Borrowing.Protocol` | `borrowing` | Non-destructive span access |
///
/// `~Copyable` types that need non-destructive iteration should conform to
/// `Sequence.Borrowing.Protocol`.
///
/// ## Property.Inout operations
///
/// `.forEach { }`, `.contains { }`, `.first { }`, `.satisfies.all { }`,
/// `.reduce.into(_:) { }` — these work through `base.value.makeIterator()` (an implicit
/// copy), so they require **Copyable** conformers with an infallible iterator
/// (`Iterator.Failure == Never`). `~Copyable` conformers use the consuming pipeline or
/// `Sequence.Borrowing.Protocol`.
///
/// `.count`, `.count(where:)`, and `.collect()` are direct consuming terminals (gated on
/// `Element: Copyable`); they propagate the iterator's `Failure`.
///
/// ## Difference from stdlib `Sequence`
///
/// | Aspect | stdlib `Sequence` | `Sequenceable` |
/// |--------|-------------------|----------------|
/// | Container `~Copyable` | No | Yes |
/// | Element `~Copyable` | No | Yes |
/// | `for-in` syntax | Yes | No (use `.forEach`) |
/// | Iterator requirement | `IteratorProtocol` | `Iterator.`Protocol`` (swift-iterator-primitives) |
/// | `makeIterator()` | Non-consuming | `consuming` |
/// | Pipeline | Eager | Lazy (`.collect()` materializes) |
public protocol Sequenceable<Element>: ~Copyable, ~Escapable {
    /// The type of element produced by the sequence.
    ///
    /// Supports move-only elements (file descriptors, unique handles) via `~Copyable`, and
    /// non-escaping elements (views into iterator-owned storage) via `~Escapable` — the scalar
    /// foundation `Iterator.`Protocol`` carries no `Span` ceiling, so the former
    /// `Element: Escapable` block (a consequence of being bulk-first) lifts here (§2 bonus / A8).
    ///
    /// The relaxation follows the extraction-vs-borrow split (mirroring the foundation `Iterable`
    /// terminals): borrowing/in-loop terminals (`forEach` with a `(borrowing Element)` body) admit
    /// `~Escapable`; *extraction* terminals that return an element by value past the iterator
    /// (`collect`, `first`) constrain `Element: Escapable` (the foundation scalar `next()` is
    /// uniformly `@_lifetime(&self)`, so a returned element would otherwise escape its scope). The
    /// bulk path (`Iterator.Chunk.`Protocol``) stays `Escapable`-narrowed (the `Span` ceiling).
    associatedtype Element: ~Copyable & ~Escapable

    /// The iterator type that produces elements — the foundation `Iterator.`Protocol``.
    ///
    /// Suppresses both `Copyable` and `Escapable` to admit iterators that manage heap
    /// allocations (`~Copyable` for `deinit`) or borrow from the sequence (`~Escapable`).
    /// Conformers providing plain `Copyable` + `Escapable` iterators satisfy it automatically.
    associatedtype Iterator: Iterator_Primitive.Iterator.`Protocol`, ~Copyable, ~Escapable
    where Iterator.Element == Element

    /// Returns an iterator over the elements of this sequence.
    ///
    /// Consumes `self` to enable lazy composition — each pipeline stage stores the
    /// consumed source inside the wrapper type.
    ///
    /// - Returns: An iterator that produces elements of type `Element`.
    @_lifetime(copy self)
    consuming func makeIterator() -> Iterator
}
