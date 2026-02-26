import Testing
import Sequence_Primitives_Test_Support

@Suite("Sequence.First")
struct SequenceFirstTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceFirstTests.Unit {
    @Test
    func `first matching element found`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.first { $0 > 3 }
        #expect(result == 4)
    }

    @Test
    func `first returns earliest match`() {
        var source = Sequence.Fixture.Source([10, 20, 30, 40])
        let result = source.first { $0 % 2 == 0 }
        #expect(result == 10)
    }
}

// MARK: - EdgeCase

extension SequenceFirstTests.EdgeCase {
    @Test
    func `first with no match returns nil`() {
        var source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.first { $0 > 100 }
        #expect(result == nil)
    }

    @Test
    func `first on empty sequence returns nil`() {
        var source = Sequence.Fixture.Source<Int>([])
        let result = source.first { _ in true }
        #expect(result == nil)
    }
}
