public import Property_Inout

extension Property::Property.Inout
where
    Base: Sequenceable,
    Base.Element: Copyable,
    Base.Iterator.Failure == Never,
    Tag == Sequence.Contains
{

    @inlinable
    public func callAsFunction(_ predicate: (borrowing Base.Element) -> Bool) -> Bool {
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            if predicate(element) { return true }
        }
        return false
    }
}
