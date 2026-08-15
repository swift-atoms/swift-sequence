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

// MARK: - Unit

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

// MARK: - Edge Case

extension Sequence.ForEach.Test.`Edge Case` {
    @Test
    func `forEach on empty sequence does nothing`() {
        var source = Sequence.Fixture.Source<Int>([])
        var count = 0
        source.forEach { _ in count += 1 }
        #expect(count == 0)
    }
}

// MARK: - Integration

extension Sequence.ForEach.Test.Integration {
    /// Custom error type used to verify typed-throws preservation across iteration.
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
            // The catch binding's static type is Stop — typed throws preserved.
            #expect(error == .at(3))
        }
        // Iteration stops at the throw — elements before are visited, after are not.
        #expect(visited == [1, 2])
    }

    @Test
    func `typed-throws forEach with non-throwing closure visits every element`() {
        // A typed-throws function whose closure never throws still iterates fully.
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
                throw Stop.at(0)  // would throw on any element, but there are none
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
        // This test documents the overload-resolution split: the call-site
        // syntax `source.forEach { body }` resolves to the Property.Inout
        // accessor's callAsFunction for non-throwing closures (verified by
        // the Unit-suite tests above) and to the typed-throws direct method
        // for closures with a typed `throws(E)` clause (verified here).
        var source = Sequence.Fixture.Source([7, 8, 9])
        var visited: [Int] = []

        // Non-throwing call (Property.Inout accessor path).
        source.forEach { visited.append($0) }
        #expect(visited == [7, 8, 9])

        // Typed-throws call (direct method path) — same syntax, different
        // resolution. The fact that this compiles confirms the typed-throws
        // overload is reachable on `Sequence.Protocol where Self: Copyable`.
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
