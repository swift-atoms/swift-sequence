public import Cardinal
public import Cardinal_Carrier
public import Property_Inout

extension Property.Inout
where Base: Sequenceable, Base: ~Copyable, Tag == Sequence.Hint {

    @inlinable
    public var count: Cardinal { .zero }
}
