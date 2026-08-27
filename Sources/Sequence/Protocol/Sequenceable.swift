public import Iterator

public protocol Sequenceable<Element>: ~Copyable, ~Escapable {

    associatedtype Element: ~Copyable & ~Escapable

    associatedtype Iterator: Iterating, ~Copyable, ~Escapable
    where Iterator.Element == Element

    @_lifetime(copy self)
    consuming func makeIterator() -> Iterator
}
