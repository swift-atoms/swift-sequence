public import Iterator_Protocol

public protocol Sequenceable<Element>: ~Copyable, ~Escapable {

    associatedtype Element: ~Copyable & ~Escapable

    associatedtype Iterator: Iterator_Primitive.Iterator.`Protocol`, ~Copyable, ~Escapable
    where Iterator.Element == Element

    @_lifetime(copy self)
    consuming func makeIterator() -> Iterator
}
