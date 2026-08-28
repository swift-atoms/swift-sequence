public import Cardinal
public import Cardinal_Carrier
public import Either
public import Iterator_Chunk
public import Sequence_Borrowing

extension Sequence.Borrowing.`Protocol`
where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {

    @inlinable
    public borrowing func reduce<Result: ~Copyable, E: Swift.Error>(
        into initial: consuming Result,
        _ accumulate: (inout Result, borrowing Element) throws(E) -> Void
    ) throws(E) -> Result {
        var result = initial
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { return result }
            for index in span.indices {
                try accumulate(&result, span[index])
            }
        }
    }
}

extension Sequence.Borrowing.`Protocol`
where Self: ~Copyable & ~Escapable {

    @inlinable
    public borrowing func reduce<Result: ~Copyable, E: Swift.Error>(
        into initial: consuming Result,
        _ accumulate: (inout Result, borrowing Element) throws(E) -> Void
    ) throws(Either<E, Iterator.Failure>) -> Result {
        var result = initial
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Element>
            do throws(Iterator.Failure) {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch {
                throw Either.right(error)
            }
            if span.isEmpty { return result }
            for index in span.indices {
                do throws(E) {
                    try accumulate(&result, span[index])
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
