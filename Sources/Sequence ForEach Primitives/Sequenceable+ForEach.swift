public import Either_Primitives

extension Sequenceable where Self: ~Copyable {

    @_disfavoredOverload
    @inlinable
    public var forEach: Property<Sequence.ForEach, Self>.Inout {
        mutating _read {
            yield Property<Sequence.ForEach, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.ForEach, Self>.Inout(&self)
            yield &accessor
        }
    }
}

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

extension Sequenceable where Self: Copyable, Element: Copyable {

    @_disfavoredOverload
    @inlinable
    public func forEach<E: Swift.Error>(
        _ body: (Element) throws(E) -> Void
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
