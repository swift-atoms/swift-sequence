import Sequence_Primitives_Test_Support
import Testing

@Suite("Sequence.Drain")
struct SequenceDrainTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceDrainTests.Unit {
    @Test
    func `drain visits all elements and empties source`() {
        var source = Sequence.Fixture.DrainableSource([1, 2, 3, 4, 5])
        var visited: [Int] = []
        source.drain { visited.append($0) }
        #expect(visited == [1, 2, 3, 4, 5])
    }

    @Test
    func `drain transfers ownership of elements`() {
        var source = Sequence.Fixture.DrainableSource([10, 20, 30])
        var sum = 0
        source.drain { sum += $0 }
        #expect(sum == 60)
    }
}

// MARK: - EdgeCase

extension SequenceDrainTests.EdgeCase {
    @Test
    func `drain on empty source does nothing`() {
        var source = Sequence.Fixture.DrainableSource<Int>([])
        var count = 0
        source.drain { _ in count += 1 }
        #expect(count == 0)
    }
}
