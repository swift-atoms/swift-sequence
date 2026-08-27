public import Iterator

extension Sequenceable where Self: ~Copyable, Element: Escapable, Iterator.Failure == Never {

    @inlinable
    public consuming func consume<E: Swift.Error>(
        _ body: (consuming Element) throws(E) -> Void
    ) throws(E) {
        var iterator = makeIterator()
        while let element = iterator.next() {
            try body(element)
        }
    }
}
