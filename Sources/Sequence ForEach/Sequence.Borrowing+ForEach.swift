public import Cardinal
public import Cardinal_Carrier
public import Either
public import Iterator_Chunk
public import Sequence_Borrowing

extension Sequence.Borrowing.`Protocol`
where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {

    @inlinable
    public borrowing func forEach<E: Swift.Error>(
        _ body: (borrowing Element) throws(E) -> Void
    ) throws(E) {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { return }
            for index in span.indices {
                try body(span[index])
            }
        }
    }
}

extension Sequence.Borrowing.`Protocol`
where Self: ~Copyable & ~Escapable {

    @inlinable
    public borrowing func forEach<E: Swift.Error>(
        _ body: (borrowing Element) throws(E) -> Void
    ) throws(Either<E, Iterator.Failure>) {
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Element>
            do throws(Iterator.Failure) {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch {
                throw Either.right(error)
            }
            if span.isEmpty { return }
            for index in span.indices {
                do throws(E) {
                    try body(span[index])
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
