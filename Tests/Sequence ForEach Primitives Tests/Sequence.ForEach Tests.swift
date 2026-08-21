import Sequence_Primitives_Test_Support
import Testing

extension Sequence.ForEach {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.ForEach.Test.Unit {
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
}

extension Sequence.ForEach.Test.`Edge Case` {
    @Test
    func `forEach on empty sequence does nothing`() {
        var source = Sequence.Fixture.Source<Int>([])
        var count = 0
        source.forEach { _ in count += 1 }
        #expect(count == 0)
    }
}

extension Sequence.ForEach.Test.Integration {

    enum Stop: Swift.Error, Equatable {
        case at(Int)
    }

    @Test
    func `typed-throws forEach propagates closure error with typed shape`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        var visited: [Int] = []
        do throws(Stop) {
            try source.forEach { element throws(Stop) in
                if element == 3 { throw Stop.at(element) }
                visited.append(element)
            }
            Issue.record("forEach should have thrown Stop.at(3)")
        } catch {

            #expect(error == .at(3))
        }

        #expect(visited == [1, 2])
    }

    @Test
    func `typed-throws forEach with non-throwing closure visits every element`() {

        let source = Sequence.Fixture.Source([10, 20, 30])
        var visited: [Int] = []
        do throws(Stop) {
            try source.forEach { element throws(Stop) in
                visited.append(element)
            }
        } catch {
            Issue.record("forEach should not have thrown; got \(error)")
        }
        #expect(visited == [10, 20, 30])
    }

    @Test
    func `typed-throws forEach on empty sequence does not throw`() {
        let source = Sequence.Fixture.Source<Int>([])
        var visitCount = 0
        do throws(Stop) {
            try source.forEach { _ throws(Stop) in
                visitCount += 1
                throw Stop.at(0)
            }
        } catch {
            Issue.record("forEach on empty sequence should not throw; got \(error)")
        }
        #expect(visitCount == 0)
    }

    @Test
    func
        `non-throwing closure resolves via accessor; typed-throws closure resolves via direct method`()
    {

        var source = Sequence.Fixture.Source([7, 8, 9])
        var visited: [Int] = []

        source.forEach { visited.append($0) }
        #expect(visited == [7, 8, 9])

        visited.removeAll()
        do throws(Stop) {
            try source.forEach { element throws(Stop) in
                visited.append(element)
            }
        } catch {
            Issue.record("unexpected throw: \(error)")
        }
        #expect(visited == [7, 8, 9])
    }
}
