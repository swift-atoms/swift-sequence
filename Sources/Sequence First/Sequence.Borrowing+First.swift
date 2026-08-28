public import Cardinal
public import Cardinal_Carrier
public import Either
public import Iterator_Chunk
public import Sequence_Borrowing

extension Sequence.Borrowing.`Protocol`
where
    Self: ~Copyable & ~Escapable,
    Element: Copyable & Escapable,
    Iterator.Failure == Never
{

    @inlinable
    public borrowing func first<E: Swift.Error>(
        where predicate: (borrowing Element) throws(E) -> Bool
    ) throws(E) -> Element? {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { return nil }
            for index in span.indices {
                let element = span[index]
                if try predicate(element) { return element }
            }
        }
    }
}

extension Sequence.Borrowing.`Protocol`
where Self: ~Copyable & ~Escapable, Element: Copyable & Escapable {

    @inlinable
    public borrowing func first<E: Swift.Error>(
        where predicate: (borrowing Element) throws(E) -> Bool
    ) throws(Either<E, Iterator.Failure>) -> Element? {
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Element>
            do throws(Iterator.Failure) {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch {
                throw Either.right(error)
            }
            if span.isEmpty { return nil }
            for index in span.indices {
                let element = span[index]
                do throws(E) {
                    if try predicate(element) { return element }
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
