public import Iterator
public import Property

public protocol Sequenceable<Element>: ~Copyable, ~Escapable {

    associatedtype Element: ~Copyable & ~Escapable

    associatedtype Iterator: Iterator::Iterator.`Protocol`, ~Copyable, ~Escapable
    where Iterator.Element == Element

    @_lifetime(copy self)
    consuming func makeIterator() -> Iterator
}

extension Sequenceable where Self: ~Copyable {

    @inlinable
    public var contains: Property<Sequence.Contains, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Contains, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Contains, Self>.Inout(&self)
            yield &accessor
        }
    }
}

extension Sequenceable where Self: ~Copyable {

    @inlinable
    public var hint: Property<Sequence.Hint, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Hint, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Hint, Self>.Inout(&self)
            yield &accessor
        }
    }
}

extension Sequenceable where Self: ~Copyable {

    @inlinable
    public var reduce: Property<Sequence.Reduce, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Reduce, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Reduce, Self>.Inout(&self)
            yield &accessor
        }
    }
}

extension Sequenceable where Self: ~Copyable {

    @inlinable
    public var satisfies: Property<Sequence.Satisfies, Self>.Inout {
        mutating _read {
            yield Property<Sequence.Satisfies, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Sequence.Satisfies, Self>.Inout(&self)
            yield &accessor
        }
    }
}
