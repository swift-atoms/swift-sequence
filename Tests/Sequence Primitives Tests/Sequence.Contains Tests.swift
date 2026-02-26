import Testing
import Sequence_Primitives_Test_Support

@Suite("Sequence.Contains")
struct SequenceContainsTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceContainsTests.Unit {
    @Test
    func `contains returns true when element matches`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        #expect(source.contains { $0 == 3 })
    }

    @Test
    func `contains returns false when no element matches`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        #expect(!source.contains { $0 == 10 })
    }
}

// MARK: - EdgeCase

extension SequenceContainsTests.EdgeCase {
    @Test
    func `contains on empty sequence returns false`() {
        var source = Sequence.Fixture.Source<Int>([])
        #expect(!source.contains { _ in true })
    }

    @Test
    func `contains short-circuits on first match`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        var count = 0
        _ = source.contains {
            count += 1
            return $0 == 2
        }
        #expect(count == 2)
    }
}
