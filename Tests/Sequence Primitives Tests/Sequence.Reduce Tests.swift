import Testing
import Sequence_Primitives_Test_Support

@Suite("Sequence.Reduce")
struct SequenceReduceTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceReduceTests.Unit {
    @Test
    func `reduce into accumulates with mutable state`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let sum = source.reduce.into(0) { $0 += $1 }
        #expect(sum == 15)
    }

    @Test
    func `reduce from accumulates with immutable folding`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let product = source.reduce.from(1) { $0 * $1 }
        #expect(product == 120)
    }

    @Test
    func `reduce into builds collection`() {
        var source = Sequence.Fixture.Source([1, 2, 3])
        let strings = source.reduce.into([String]()) { $0.append(String($1)) }
        #expect(strings == ["1", "2", "3"])
    }
}

// MARK: - EdgeCase

extension SequenceReduceTests.EdgeCase {
    @Test
    func `reduce into on empty sequence returns initial`() {
        var source = Sequence.Fixture.Source<Int>([])
        let result = source.reduce.into(42) { $0 += $1 }
        #expect(result == 42)
    }

    @Test
    func `reduce from on empty sequence returns initial`() {
        var source = Sequence.Fixture.Source<Int>([])
        let result = source.reduce.from(99) { $0 + $1 }
        #expect(result == 99)
    }
}
