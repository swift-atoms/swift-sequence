import Sequence_Primitives_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Span Iterator Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.`Span Iterator Test`.Unit {
    @Test
    func `next returns elements in order`() {
        let array = [10, 20, 30]
        unsafe array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator(span: span)
            #expect(iterator.next() == 10)
            #expect(iterator.next() == 20)
            #expect(iterator.next() == 30)
            #expect(iterator.next() == nil)
        }
    }

    @Test
    func `isEmpty reflects exhaustion state`() {
        let array = [1, 2]
        unsafe array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator(span: span)

            var empty = iterator.isEmpty
            #expect(!empty)

            _ = iterator.next()
            empty = iterator.isEmpty
            #expect(!empty)

            _ = iterator.next()
            empty = iterator.isEmpty
            #expect(empty)
        }
    }

    @Test
    func `remaining decrements with each next`() {
        let array = [1, 2, 3]
        unsafe array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator(span: span)

            var rem = iterator.remaining
            #expect(rem == 3)

            _ = iterator.next()
            rem = iterator.remaining
            #expect(rem == 2)

            _ = iterator.next()
            rem = iterator.remaining
            #expect(rem == 1)

            _ = iterator.next()
            rem = iterator.remaining
            #expect(rem == .zero)
        }
    }
}

extension Sequence.`Span Iterator Test`.`Edge Case` {
    @Test
    func `iterator over empty span`() {
        let array: [Int] = []
        unsafe array.withUnsafeBufferPointer { buffer in
            let span = unsafe Span(_unsafeElements: buffer)
            var iterator = Swift.Span<Int>.Iterator(span: span)

            let empty = iterator.isEmpty
            #expect(empty)

            let rem = iterator.remaining
            #expect(rem == .zero)

            #expect(iterator.next() == nil)
        }
    }
}
