public import Cardinal

extension Sequenceable where Self: ~Copyable, Element: Copyable {

    @inlinable
    public consuming func count(
        where predicate: (borrowing Element) -> Bool
    ) throws(Iterator.Failure) -> Cardinal {
        var count = Cardinal(0)
        var iterator = self.makeIterator()
        while let element = try iterator.next() {
            if predicate(element) { count += Cardinal(1) }
        }
        return count
    }
}
