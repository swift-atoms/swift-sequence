public import Index_Primitives

extension Property.Inout
where Base: Sequenceable, Base: ~Copyable, Tag == Sequence.Hint {

    @inlinable
    public var count: Cardinal { .zero }
}
