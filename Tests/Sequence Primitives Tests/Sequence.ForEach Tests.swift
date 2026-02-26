import Testing
import Sequence_Primitives_Test_Support

@Suite("Sequence.ForEach")
struct SequenceForEachTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceForEachTests.Unit {
    @Test
    func `forEach visits every element in order`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        var visited: [Int] = []
        source.forEach { visited.append($0) }
        #expect(visited == [1, 2, 3, 4, 5])
    }

    @Test
    func `forEach borrowing visits every element`() {
        var source = Sequence.Fixture.Source([10, 20, 30])
        var visited: [Int] = []
        source.forEach.borrowing { visited.append($0) }
        #expect(visited == [10, 20, 30])
    }

    @Test
    func `forEach consuming drains and clears`() {
        var source = Sequence.Fixture.ClearableSource([1, 2, 3])
        var visited: [Int] = []
        source.forEach.consuming { visited.append($0) }
        #expect(visited == [1, 2, 3])
    }
}

// MARK: - EdgeCase

extension SequenceForEachTests.EdgeCase {
    @Test
    func `forEach on empty sequence does nothing`() {
        var source = Sequence.Fixture.Source<Int>([])
        var count = 0
        source.forEach { _ in count += 1 }
        #expect(count == 0)
    }
}
