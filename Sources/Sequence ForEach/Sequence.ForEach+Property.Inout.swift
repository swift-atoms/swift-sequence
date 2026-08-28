public import Property

extension Property.Inout
where
    Base: Sequenceable,
    Base.Element: Copyable,
    Base.Iterator.Failure == Never,
    Tag == Sequence.ForEach
{

    @inlinable
    public func callAsFunction(_ body: (borrowing Base.Element) -> Void) {
        borrowing(body)
    }

    @inlinable
    public func borrowing(_ body: (borrowing Base.Element) -> Void) {
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            body(element)
        }
    }
}
