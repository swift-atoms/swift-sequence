public import Iterator
public import Sequence

extension Sequenceable
where Self: Copyable, Element: Copyable & Escapable, Iterator.Failure == Never {

    @inlinable
    public var first: Element? {
        var iterator = makeIterator()
        return iterator.next()
    }
}
