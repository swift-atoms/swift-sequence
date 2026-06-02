public import Index_Primitives

/// Property.Inout extensions for iteration-hint operations on
/// `Sequence.Protocol` conformers.
extension Property.Inout
where Base: Sequenceable, Base: ~Copyable, Tag == Sequence.Hint {

    /// Underestimate of element count via `.hint.count`.
    ///
    /// Returns an underestimate of the number of elements the sequence
    /// will produce. The default is `.zero` — conformers with a cheap
    /// count estimate override on a concrete-Base extension.
    ///
    /// ```swift
    /// extension Property.Inout
    /// where Base == MyContainer, Tag == Sequence.Hint {
    ///     public var count: Cardinal { base.value.storedCount }
    /// }
    /// ```
    ///
    /// ## Use as Capacity Hint
    ///
    /// `.collect()` calls this before iteration to pre-allocate the
    /// result array, avoiding repeated reallocation during the eager
    /// walk.
    ///
    /// - Returns: An underestimate of the element count.
    @inlinable
    public var count: Cardinal { .zero }
}
