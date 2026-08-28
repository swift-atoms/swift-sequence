public import Property_Inout
public import Sequence_Protocol

extension Sequenceable where Self: ~Copyable {

    @inlinable
    public var first: Property<Sequence.First, Self>.Inout {
        mutating _read {
            yield Property<Sequence.First, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.First, Self>.Inout(&self)
            yield &accessor
        }
    }
}

extension Sequenceable
where Self: Copyable, Element: Copyable & Escapable, Iterator.Failure == Never {

    @inlinable
    public var first: Element? {
        var iterator = makeIterator()
        return iterator.next()
    }
}
