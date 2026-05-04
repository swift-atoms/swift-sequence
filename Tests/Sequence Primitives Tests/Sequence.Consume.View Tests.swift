import Sequence_Primitives_Test_Support
import Testing

@Suite("Sequence.Consume.View")
struct SequenceConsumeViewTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

// MARK: - Unit

extension SequenceConsumeViewTests.Unit {
    @Test
    func `next returns elements in order`() {
        var view = Sequence.Consume.View<Int, [Int]>(
            state: [1, 2, 3]
        ) { state -> Int? in
            state.isEmpty ? nil : state.removeFirst()
        }
        #expect(view.next() == 1)
        #expect(view.next() == 2)
        #expect(view.next() == 3)
        #expect(view.next() == nil)
    }

    @Test
    func `forEach visits all elements`() {
        let view = Sequence.Consume.View<Int, [Int]>(
            state: [10, 20, 30]
        ) { state -> Int? in
            state.isEmpty ? nil : state.removeFirst()
        }
        var visited: [Int] = []
        view.forEach { visited.append($0) }
        #expect(visited == [10, 20, 30])
    }
}

// MARK: - EdgeCase

extension SequenceConsumeViewTests.EdgeCase {
    @Test
    func `next on empty state returns nil immediately`() {
        var view = Sequence.Consume.View<Int, [Int]>(
            state: []
        ) { state -> Int? in
            state.isEmpty ? nil : state.removeFirst()
        }
        #expect(view.next() == nil)
    }

    @Test
    func `forEach on empty state does nothing`() {
        let view = Sequence.Consume.View<Int, [Int]>(
            state: []
        ) { state -> Int? in
            state.isEmpty ? nil : state.removeFirst()
        }
        var count = 0
        view.forEach { _ in count += 1 }
        #expect(count == 0)
    }
}
