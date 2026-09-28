#if CardinalSpan
import Cardinal
import Ordinal
import Sequence
import Testing

@Suite("Span × Cardinal and Ordinal")
struct Span_Cardinal_Tests {

    @Test
    func `cardinal counts extract prefixes and suffixes`() {
        let values = [10, 20, 30, 40]
        values.withUnsafeBufferPointer { buffer in
            let span = unsafe Swift.Span(_unsafeElements: buffer)
            let prefix = span.extracting(first: Cardinal(UInt(2)))
            let suffix = span.extracting(droppingFirst: Cardinal(UInt(2)))

            #expect(prefix.count == 2)
            #expect(prefix[0] == 10)
            #expect(prefix[1] == 20)
            #expect(suffix.count == 2)
            #expect(suffix[0] == 30)
            #expect(suffix[1] == 40)
        }
    }

    @Test
    func `ordinal positions address span elements`() {
        let values = [10, 20, 30]
        values.withUnsafeBufferPointer { buffer in
            let span = unsafe Swift.Span(_unsafeElements: buffer)
            #expect(span[Ordinal(UInt(1))] == 20)
        }
    }
}
#endif
