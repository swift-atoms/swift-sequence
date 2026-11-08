import Cardinal
import Iterator
import Ownership
import Property
import Sequence
import Tagged
import Testing

@Suite
struct Sequence_Drain_Property_Tests {}

extension Sequence_Drain_Property_Tests {
    @Test
    func `drain visits all elements and empties source`() {
        var source = Sequence.Fixture.Drainable.Source([1, 2, 3, 4, 5])
        var visited: [Int] = []
        do {
            var drain = Property<Sequence.Drain, Sequence.Fixture.Drainable.Source<Int>>.Inout(
                &source
            )
            drain { visited.append($0) }
        }
        #expect(visited == [1, 2, 3, 4, 5])
        #expect(source.elements.isEmpty)
    }

    @Test
    func `drain transfers ownership of elements`() {
        var source = Sequence.Fixture.Drainable.Source([10, 20, 30])
        var sum = 0
        do {
            var drain = Property<Sequence.Drain, Sequence.Fixture.Drainable.Source<Int>>.Inout(
                &source
            )
            drain { sum += $0 }
        }
        #expect(sum == 60)
        #expect(source.elements.isEmpty)
    }
}

extension Sequence_Drain_Property_Tests {
    @Test
    func `drain on empty source does nothing`() {
        var source = Sequence.Fixture.Drainable.Source<Int>([])
        var count = 0
        do {
            var drain = Property<Sequence.Drain, Sequence.Fixture.Drainable.Source<Int>>.Inout(
                &source
            )
            drain { _ in count += 1 }
        }
        #expect(count == 0)
    }
}
