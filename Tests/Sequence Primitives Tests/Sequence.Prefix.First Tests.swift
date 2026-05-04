import Sequence_Primitives_Test_Support
import Testing

@Suite("Sequence.Prefix.First")
struct SequencePrefixFirstTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequencePrefixFirstTests.Unit {
    @Test
    func `prefix first N elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.prefix(first: Cardinal(3)).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `prefix first 1 element`() {
        let source = Sequence.Fixture.Source([10, 20, 30])
        let result = source.prefix(first: Cardinal(1)).collect()
        #expect(result == [10])
    }
}

// MARK: - EdgeCase

extension SequencePrefixFirstTests.EdgeCase {
    @Test
    func `prefix zero elements returns empty`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.prefix(first: .zero).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `prefix more than count returns all`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.prefix(first: Cardinal(10)).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `prefix from empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.prefix(first: Cardinal(5)).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `prefix exactly count returns all`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.prefix(first: Cardinal(3)).collect()
        #expect(result == [1, 2, 3])
    }
}
