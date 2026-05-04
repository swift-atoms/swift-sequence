import Sequence_Primitives_Test_Support
import Testing

@Suite("Span.Iterator.Batch")
struct SpanIteratorBatchTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SpanIteratorBatchTests.Unit {
    @Test
    func `nextSpan returns batches of requested size`() {
        let array = [1, 2, 3, 4, 5, 6]
        unsafe array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            var count = iterator.nextSpan(maximumCount: Cardinal(3)).count
            #expect(count == 3)

            count = iterator.nextSpan(maximumCount: Cardinal(3)).count
            #expect(count == 3)

            count = iterator.nextSpan(maximumCount: Cardinal(3)).count
            #expect(count == 0)
        }
    }

    @Test
    func `nextSpan returns partial last batch`() {
        let array = [1, 2, 3, 4, 5]
        unsafe array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator.Batch(span: span)

            var count = iterator.nextSpan(maximumCount: Cardinal(3)).count
            #expect(count == 3)

            count = iterator.nextSpan(maximumCount: Cardinal(3)).count
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

            _ = iterator.nextSpan(maximumCount: Cardinal(2))
            rem = iterator.remaining
            #expect(rem == 2)

            _ = iterator.nextSpan(maximumCount: Cardinal(2))
            rem = iterator.remaining
            #expect(rem == .zero)
        }
    }
}

// MARK: - EdgeCase

extension SpanIteratorBatchTests.EdgeCase {
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

            let count = iterator.nextSpan(maximumCount: Cardinal(5)).count
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
