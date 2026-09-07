public import Either

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

extension Sequenceable where Self: ~Copyable, Element: Escapable {

    @inlinable
    public consuming func consume<E: Swift.Error>(
        _ body: (consuming Element) throws(E) -> Void
    ) throws(Either<E, Iterator.Failure>) {
        var iterator = makeIterator()
        while true {
            let step: Element?
            do throws(Iterator.Failure) {
                step = try iterator.next()
            } catch {
                throw Either.right(error)
            }
            guard let element = step else { return }
            do throws(E) {
                try body(element)
            } catch {
                throw Either.left(error)
            }
        }
    }
}
