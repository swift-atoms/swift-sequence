public import Property_Primitives

extension Property.Inout
where Base: Sequence.Drain.`Protocol` & ~Copyable, Tag == Sequence.Drain {

    @inlinable
    public mutating func callAsFunction(_ body: (consuming Base.Element) -> Void) {
        base.value.drain(body)
    }
}
