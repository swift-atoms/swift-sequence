public import Cardinal
public import Cardinal_Carrier
public import Either
public import Iterator_Chunk
public import Sequence_Borrowing

extension Sequence.Borrowing.`Protocol`
where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {

    @inlinable
    public borrowing func contains<E: Swift.Error>(
        where predicate: (borrowing Element) throws(E) -> Bool
    ) throws(E) -> Bool {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { return false }
            for index in span.indices {
                if try predicate(span[index]) { return true }
            }
        }
    }
}

extension Sequence.Borrowing.`Protocol`
where Self: ~Copyable & ~Escapable {

    @inlinable
    public borrowing func contains<E: Swift.Error>(
        where predicate: (borrowing Element) throws(E) -> Bool
    ) throws(Either<E, Iterator.Failure>) -> Bool {
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Element>
            do throws(Iterator.Failure) {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch {
                throw Either.right(error)
            }
            if span.isEmpty { return false }
            for index in span.indices {
                do throws(E) {
                    if try predicate(span[index]) { return true }
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
