import Cardinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Span batch iterators preserve ordered batches and skipped counts` {
        @Suite struct `Span batch iteration preserves batch sizes and remaining elements` {}
        @Suite struct `Span batch iteration handles empty spans and oversized skips` {}
        @Suite struct `No span batch iteration integration cases are defined` {}
    }
}

extension Sequence.`Span batch iterators preserve ordered batches and skipped counts`.`Span batch iteration preserves batch sizes and remaining elements` {
    @Test
    func `next(maximumCount:) returns batches of requested size`() {
        let array = [1, 2, 3, 4, 5, 6]
        array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            var count = iterator.next(maximumCount: Cardinal(3)).count
            #expect(count == 3)

            count = iterator.next(maximumCount: Cardinal(3)).count
            #expect(count == 3)

            count = iterator.next(maximumCount: Cardinal(3)).count
            #expect(count == 0)
        }
    }

    @Test
    func `next(maximumCount:) returns partial last batch`() {
        let array = [1, 2, 3, 4, 5]
        array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            var count = iterator.next(maximumCount: Cardinal(3)).count
            #expect(count == 3)

            count = iterator.next(maximumCount: Cardinal(3)).count
            #expect(count == 2)
        }
    }

    @Test
    func `skip advances past elements`() {
        let array = [1, 2, 3, 4, 5]
        array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            let skipped = iterator.skip(by: Cardinal(2))
            #expect(skipped == 2)

            let rem = iterator.remaining
            #expect(rem == 3)
        }
    }

    @Test
    func `remaining tracks available elements`() {
        let array = [1, 2, 3, 4]
        array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            var rem = iterator.remaining
            #expect(rem == 4)

            _ = iterator.next(maximumCount: Cardinal(2))
            rem = iterator.remaining
            #expect(rem == 2)

            _ = iterator.next(maximumCount: Cardinal(2))
            rem = iterator.remaining
            #expect(rem == Cardinal(0))
        }
    }
}

extension Sequence.`Span batch iterators preserve ordered batches and skipped counts`.`Span batch iteration handles empty spans and oversized skips` {
    @Test
    func `An empty span batch iterator returns no elements`() {
        let array: [Int] = []
        array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            let empty = iterator.isEmpty
            #expect(empty)

            let rem = iterator.remaining
            #expect(rem == Cardinal(0))

            let count = iterator.next(maximumCount: Cardinal(5)).count
            #expect(count == 0)
        }
    }

    @Test
    func `skip more than remaining returns actual skipped`() {
        let array = [1, 2, 3]
        array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            let skipped = iterator.skip(by: Cardinal(10))
            #expect(skipped == 3)

            let empty = iterator.isEmpty
            #expect(empty)
        }
    }
}
