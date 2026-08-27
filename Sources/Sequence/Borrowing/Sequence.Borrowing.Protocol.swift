public import Iterator_Chunk

extension Sequence.Borrowing {

    public protocol `Protocol`<Element>: ~Copyable, ~Escapable {

        associatedtype Element: ~Copyable

        associatedtype Iterator: __IteratorChunkProtocol & ~Copyable & ~Escapable
        where Iterator.Element == Element

        @_lifetime(borrow self)
        borrowing func makeIterator() -> Iterator
    }
}
