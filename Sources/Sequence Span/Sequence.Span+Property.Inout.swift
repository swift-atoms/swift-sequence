public import Index
public import Iterator_Chunk
import Property
public import Sequence_Borrowing

extension Property.Inout
where
    Base: Sequence.Borrowing.`Protocol` & ~Copyable,
    Base.Iterator.Failure == Never,
    Tag == Sequence.Span
{

    @inlinable
    public func forEach(_ body: (Swift.Span<Base.Element>) -> Void) {
        func loop(_ source: borrowing Base) {
            var iterator = source.makeIterator()
            while true {
                let span = iterator.next(maximumCount: Cardinal.max)
                if span.isEmpty { break }
                body(span)
            }
        }
        loop(base.value)
    }

    @inlinable
    public func elements(_ body: (borrowing Base.Element) -> Void) {
        func loop(_ source: borrowing Base) {
            var iterator = source.makeIterator()
            while true {
                let span = iterator.next(maximumCount: Cardinal.max)
                if span.isEmpty { break }
                for i in span.indices {
                    body(span[i])
                }
            }
        }
        loop(base.value)
    }

    @inlinable
    public func reduce<Accumulator>(
        into initial: Accumulator,
        _ operation: (inout Accumulator, Swift.Span<Base.Element>) -> Void
    ) -> Accumulator {
        var result = initial
        func loop(_ source: borrowing Base) {
            var iterator = source.makeIterator()
            while true {
                let span = iterator.next(maximumCount: Cardinal.max)
                if span.isEmpty { break }
                operation(&result, span)
            }
        }
        loop(base.value)
        return result
    }

    @inlinable
    public func reduce<Accumulator>(
        from initial: Accumulator,
        _ operation: (Accumulator, Swift.Span<Base.Element>) -> Accumulator
    ) -> Accumulator {
        var result = initial
        func loop(_ source: borrowing Base) {
            var iterator = source.makeIterator()
            while true {
                let span = iterator.next(maximumCount: Cardinal.max)
                if span.isEmpty { break }
                result = operation(result, span)
            }
        }
        loop(base.value)
        return result
    }
}
