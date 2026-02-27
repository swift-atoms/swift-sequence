extension Sequence {
    /// A protocol for types that produce elements through consuming iteration.
    ///
    /// `Sequence.Protocol` is the foundation of the lazy pipeline. Its sole
    /// requirement — `consuming func makeIterator()` — enables chaining:
    ///
    /// ```swift
    /// let result = source
    ///     .map { $0 * 2 }
    ///     .filter { $0 > 5 }
    ///     .collect()  // [Element]
    /// ```
    ///
    /// Each operation consumes the previous sequence and stores it inside
    /// the wrapper. The final `.collect()` consumes the chain and
    /// materializes it into an `Array`.
    ///
    /// ## Conforming to Sequence.Protocol
    ///
    /// Provide `makeIterator()` that returns a
    /// ``Sequence/Iterator-swift.enum/Protocol-swift.protocol`` conformer:
    ///
    /// ```swift
    /// struct Source<Element: Sendable>: Sequence.`Protocol`, Sendable {
    ///     let _elements: [Element]
    ///
    ///     consuming func makeIterator() -> Iterator { Iterator(_elements) }
    /// }
    /// ```
    ///
    /// See `Sequence.Fixture.Source` in the test support module for the
    /// minimal conformer reference.
    ///
    /// ### Why `consuming`
    ///
    /// Consuming ownership enables lazy composition. Each `.map { }`,
    /// `.filter { }`, or `.drop(first:)` call consumes the source sequence
    /// and stores it inside the lazy wrapper type. This avoids copies and
    /// allows the entire pipeline to be consumed by a terminal operation.
    ///
    /// For **Copyable conformers** (the common case), consuming a `let`
    /// binding creates an implicit copy. So `let s = Source(...); s.map { }`
    /// copies `s` — the original binding remains valid. No behavioral
    /// change from the caller's perspective.
    ///
    /// ### `@_lifetime(copy self)`
    ///
    /// Required when `Self` is `~Escapable` — tells the compiler the
    /// returned `Iterator`'s lifetime is derived from `self`'s lifetime.
    /// When `Self` is `Escapable` (the common case), the annotation is
    /// accepted but has no effect. Conformers of `Escapable` types can
    /// omit it and the compiler infers it.
    ///
    /// ### `Iterator: ... & ~Copyable & ~Escapable`
    ///
    /// The associated type suppresses both `Copyable` and `Escapable`.
    /// This allows iterators with `deinit` (the heap buffer pattern,
    /// which is `~Copyable`) and iterators whose lifetime depends on the
    /// sequence (`~Escapable`). Conformers providing
    /// `Copyable` + `Escapable` iterators satisfy this constraint
    /// automatically — no annotations needed.
    ///
    /// ## Two-Tier Iteration Model
    ///
    /// | Protocol | Ownership | Use Case |
    /// |----------|-----------|----------|
    /// | `Sequence.Protocol` | `consuming` | Lazy chains, terminal operations |
    /// | `Sequence.Borrowing.Protocol` | `borrowing` | Non-destructive span access |
    ///
    /// `~Copyable` types that need non-destructive iteration should conform
    /// to ``Sequence/Borrowing-swift.enum/Protocol-swift.protocol``.
    ///
    /// ## Property.View Operations
    ///
    /// `.forEach { }`, `.contains { }`, `.count.all`, `.first { }`,
    /// `.satisfies.all { }`, `.reduce.into(_:) { }` — these work through
    /// `base.pointee.makeIterator()` which requires an implicit copy.
    /// Therefore they only work for **Copyable** conformers. `~Copyable`
    /// conformers should use the consuming pipeline or
    /// ``Sequence/Borrowing-swift.enum/Protocol-swift.protocol``.
    ///
    /// ## Difference from stdlib `Sequence`
    ///
    /// | Aspect | stdlib `Sequence` | `Sequence.Protocol` |
    /// |--------|-------------------|---------------------|
    /// | Container `~Copyable` | No | Yes |
    /// | Element `~Copyable` | No | Yes |
    /// | `for-in` syntax | Yes | No (use `.forEach`) |
    /// | Iterator requirement | `IteratorProtocol` | `Sequence.Iterator.Protocol` |
    /// | `makeIterator()` | Non-consuming | `consuming` |
    /// | Pipeline | Eager | Lazy (`.collect()` materializes) |
    public protocol `Protocol`: ~Copyable, ~Escapable {
        /// The type of element produced by the sequence.
        associatedtype Element: ~Copyable

        /// The iterator type that produces elements.
        ///
        /// Suppresses both `Copyable` and `Escapable` to allow iterators
        /// that manage heap allocations (`~Copyable` for `deinit`) or
        /// borrow from the sequence (`~Escapable` for lifetime
        /// dependency). Conformers providing plain
        /// `Copyable` + `Escapable` iterators satisfy this automatically.
        associatedtype Iterator: Sequence.Iterator.`Protocol` & ~Copyable & ~Escapable
            where Iterator.Element == Element

        /// Returns an iterator over the elements of this sequence.
        ///
        /// Consumes `self` to enable lazy composition — each pipeline
        /// stage stores the consumed source inside the wrapper type.
        ///
        /// - `@_lifetime(copy self)`: Required for `~Escapable`
        ///   conformers. Accepted but has no effect for `Escapable`
        ///   conformers, which may omit it.
        /// - Returns: An iterator that produces elements of type
        ///   `Element`.
        @_lifetime(copy self)
        consuming func makeIterator() -> Iterator
    }
}
