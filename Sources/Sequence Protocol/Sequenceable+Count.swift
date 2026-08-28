public import Index

extension Sequenceable where Self: ~Copyable, Element: Copyable {

    @inlinable
    public consuming func count(
        where predicate: (borrowing Element) -> Bool
    ) throws(Iterator.Failure) -> Cardinal {
        var count = Cardinal.zero
        var iterator = self.makeIterator()
        while let element = try iterator.next() {
            if predicate(element) { count += .one }
        }
        return count
    }
}
