public import Property_Primitives

extension Property.Inout
where
    Base: Sequenceable,
    Base.Element: Copyable,
    Base.Iterator.Failure == Never,
    Tag == Sequence.Reduce
{

    @inlinable
    public func into<Accumulator>(
        _ initial: Accumulator,
        _ operation: (inout Accumulator, borrowing Base.Element) -> Void
    ) -> Accumulator {
        var result = initial
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            operation(&result, element)
        }
        return result
    }

    @inlinable
    public func from<Accumulator>(
        _ initial: Accumulator,
        _ operation: (Accumulator, borrowing Base.Element) -> Accumulator
    ) -> Accumulator {
        var result = initial
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            result = operation(result, element)
        }
        return result
    }
}
