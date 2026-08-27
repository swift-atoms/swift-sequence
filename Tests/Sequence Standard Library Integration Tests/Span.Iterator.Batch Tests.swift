import Sequence
import Sequence_Standard_Library_Integration
import Testing

extension Sequence {
    @Suite
    struct `Span Iterator Batch Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.`Span Iterator Batch Test`.Unit {
    @Test
    func `next(maximumCount:) returns batches of requested size`() {
        let array = [1, 2, 3, 4, 5, 6]
        unsafe array.withUnsafeBufferPointer { buffer in
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
        unsafe array.withUnsafeBufferPointer { buffer in
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
        unsafe array.withUnsafeBufferPointer { buffer in
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
        unsafe array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            var rem = iterator.remaining
            #expect(rem == 4)

            _ = iterator.next(maximumCount: Cardinal(2))
            rem = iterator.remaining
            #expect(rem == 2)

            _ = iterator.next(maximumCount: Cardinal(2))
            rem = iterator.remaining
            #expect(rem == .zero)
        }
    }
}

extension Sequence.`Span Iterator Batch Test`.`Edge Case` {
    @Test
    func `batch iterator over empty span`() {
        let array: [Int] = []
        unsafe array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            let empty = iterator.isEmpty
            #expect(empty)

            let rem = iterator.remaining
            #expect(rem == .zero)

            let count = iterator.next(maximumCount: Cardinal(5)).count
            #expect(count == 0)
        }
    }

    @Test
    func `skip more than remaining returns actual skipped`() {
        let array = [1, 2, 3]
        unsafe array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            let skipped = iterator.skip(by: Cardinal(10))
            #expect(skipped == 3)

            let empty = iterator.isEmpty
            #expect(empty)
        }
    }
}
