public import Cardinal
public import Cardinal_Carrier
public import Iterator_Chunk
public import Sequence_Borrowing

extension Sequence.Borrowing.`Protocol`
where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {

    @inlinable
    public borrowing func allSatisfy<E: Swift.Error>(
        _ predicate: (borrowing Element) throws(E) -> Bool
    ) throws(E) -> Bool {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { return true }
            for index in span.indices {
                if try !predicate(span[index]) { return false }
            }
        }
    }
}
