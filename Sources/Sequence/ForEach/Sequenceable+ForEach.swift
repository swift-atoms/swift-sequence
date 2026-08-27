extension Sequenceable where Self: Swift.Sequence, Iterator.Failure == Never {

    @inline(always)
    @inlinable
    public func forEach(_ body: (Element) -> Void) {
        var iterator = makeIterator()
        while let element = iterator.next() {
            body(element)
        }
    }
}

extension Sequenceable where Self: Copyable, Element: Copyable, Iterator.Failure == Never {

    @_disfavoredOverload
    @inlinable
    public func forEach<E: Swift.Error>(
        _ body: (Element) throws(E) -> Void
    ) throws(E) {
        var iterator = makeIterator()
        while let element = iterator.next() {
            try body(element)
        }
    }
}
