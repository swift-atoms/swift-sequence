import Sequence_Primitives_Test_Support
import Testing

@Suite("Sequence.Count")
struct SequenceCountTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceCountTests.Unit {
    @Test
    func `count all returns total element count`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let total = source.count.all
        #expect(total == 5)
    }

    @Test
    func `count where returns matching count`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6])
        let evens = source.count.where { $0 % 2 == 0 }
        #expect(evens == 3)
    }
}

// MARK: - EdgeCase

extension SequenceCountTests.EdgeCase {
    @Test
    func `count all on empty sequence returns zero`() {
        var source = Sequence.Fixture.Source<Int>([])
        #expect(source.count.all == .zero)
    }

    @Test
    func `count where with no matches returns zero`() {
        var source = Sequence.Fixture.Source([1, 2, 3])
        #expect(source.count.where { $0 > 100 } == .zero)
    }

    @Test
    func `count where with all matching returns total`() {
        var source = Sequence.Fixture.Source([1, 2, 3])
        #expect(source.count.where { _ in true } == 3)
    }
}
