public import Property_Primitives

extension Property.Inout
where
    Base: Sequenceable,
    Base.Element: Copyable,
    Base.Iterator.Failure == Never,
    Tag == Sequence.Satisfies
{

    @inlinable
    public func all(_ predicate: (borrowing Base.Element) -> Bool) -> Bool {
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            if !predicate(element) { return false }
        }
        return true
    }

    @inlinable
    public func any(_ predicate: (borrowing Base.Element) -> Bool) -> Bool {
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            if predicate(element) { return true }
        }
        return false
    }

    @inlinable
    public func none(_ predicate: (borrowing Base.Element) -> Bool) -> Bool {
        !any(predicate)
    }
}
