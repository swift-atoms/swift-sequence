public import Property_Primitives

extension Property.Inout
where
    Base: Sequenceable,
    Base.Element: Copyable & Escapable,
    Base.Iterator.Failure == Never,
    Tag == Sequence.First
{

    @inlinable
    public func callAsFunction(_ predicate: (borrowing Base.Element) -> Bool) -> Base.Element? {
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            if predicate(element) { return element }
        }
        return nil
    }
}
