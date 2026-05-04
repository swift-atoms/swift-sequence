import Sequence_Primitives_Test_Support
import Testing

@Suite("Sequence.Drop.First")
struct SequenceDropFirstTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceDropFirstTests.Unit {
    @Test
    func `drop first N elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.drop(first: Cardinal(2)).collect()
        #expect(result == [3, 4, 5])
    }

    @Test
    func `drop first 1 element`() {
        let source = Sequence.Fixture.Source([10, 20, 30])
        let result = source.drop(first: Cardinal(1)).collect()
        #expect(result == [20, 30])
    }
}

// MARK: - EdgeCase

extension SequenceDropFirstTests.EdgeCase {
    @Test
    func `drop zero elements returns all`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(first: .zero).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `drop more than count returns empty`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(first: Cardinal(10)).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `drop from empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.drop(first: Cardinal(5)).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `drop exactly count returns empty`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(first: Cardinal(3)).collect()
        #expect(result.isEmpty)
    }
}
