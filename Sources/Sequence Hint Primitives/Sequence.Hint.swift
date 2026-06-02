extension Sequence {
    /// Tag type for `.hint` property extensions.
    ///
    /// Provides cheap, conformer-supplied hints that consumers MAY use
    /// for optimization (capacity reservation, fast-path lookups). Hints
    /// are explicitly under-specified — callers MUST treat them as
    /// advisory only: `seq.hint.count` returns an *underestimate* of the
    /// actual element count, never the count itself.
    ///
    /// ## Available Operations
    ///
    /// | Operation | Description | Default |
    /// |-----------|-------------|---------|
    /// | `.hint.count` | Underestimate of element count | `.zero` |
    ///
    /// ## Use in Materializing Operations
    ///
    /// `.collect()` calls `.hint.count` for `Array.reserveCapacity`
    /// before iteration, avoiding O(log n) reallocations during the
    /// eager walk for conformers with a stored count.
    ///
    /// ## Conformer Override
    ///
    /// Conformers with a known-cheap count estimate (containers carrying
    /// a stored count, fused windows over contiguous storage) override
    /// `.hint.count` on `Property.Inout<Sequence.Hint, ConcreteType>`:
    ///
    /// ```swift
    /// extension Property.Inout
    /// where Base == MyContainer, Tag == Sequence.Hint {
    ///     public var count: Cardinal { base.value.storedCount }
    /// }
    /// ```
    public enum Hint {}
}
