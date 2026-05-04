import Sequence_Primitives_Test_Support
import Testing

@Suite("Sequence.CompactMap")
struct SequenceCompactMapTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceCompactMapTests.Unit {
    @Test
    func `compactMap removes nils`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.compactMap { $0 % 2 == 0 ? $0 : nil }.collect()
        #expect(result == [2, 4])
    }

    @Test
    func `compactMap transforms and filters`() {
        let source = Sequence.Fixture.Source(["1", "two", "3", "four"])
        let result = source.compactMap { Int($0) }.collect()
        #expect(result == [1, 3])
    }
}

// MARK: - EdgeCase

extension SequenceCompactMapTests.EdgeCase {
    @Test
    func `compactMap over empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.compactMap { $0 % 2 == 0 ? $0 : nil }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `compactMap where all return nil`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.compactMap { _ -> Int? in nil }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `compactMap where none return nil`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.compactMap { Optional($0) }.collect()
        #expect(result == [1, 2, 3])
    }
}
