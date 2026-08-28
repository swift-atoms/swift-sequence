public import Cardinal
public import Cardinal_Standard_Library_Integration

extension Sequenceable where Self: ~Copyable, Element: Copyable & Escapable {

    @inlinable
    public consuming func collect() throws(Iterator.Failure) -> [Element] {
        let hint = self.hint.count
        var iterator = self.makeIterator()
        var result: [Element] = []
        result.reserveCapacity(hint)
        while let element = try iterator.next() {
            result.append(element)
        }
        return result
    }
}
