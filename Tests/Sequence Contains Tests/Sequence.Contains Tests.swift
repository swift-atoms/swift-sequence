import Cardinal
import Either
import Sequence_Contains
import Sequence_Test_Support
import Testing

extension Sequence.Contains {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.Contains.Test.Unit {
    @Test
    func `borrowing contains short circuits`() {
        let source = Sequence.Fixture.Borrowing.Source([1, 2, 3, 4])
        var visited = 0
        let found = source.contains { element throws(Never) in
            visited += 1
            return element == 2
        }

        #expect(found)
        #expect(visited == 2)
    }

    @Test
    func `contains returns true when element matches`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        #expect(source.contains { $0 == 3 })
    }

    @Test
    func `contains returns false when no element matches`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        #expect(!source.contains { $0 == 10 })
    }
}

extension Sequence.Contains.Test.`Edge Case` {
    @Test
    func `contains on empty sequence returns false`() {
        var source = Sequence.Fixture.Source<Int>([])
        #expect(!source.contains { _ in true })
    }

    @Test
    func `contains short-circuits on first match`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        var count = 0
        _ = source.contains {
            count += 1
            return $0 == 2
        }
        #expect(count == 2)
    }
}

extension Sequence.Contains.Test.Integration {

    enum PredicateFailure: Swift.Error {
        case stop
    }

    @Test
    func `borrowing contains distinguishes iterator failure`() {
        let source = Sequence.Fixture.Borrowing.FailingSource(
            [10, 20, 30],
            failAt: Cardinal(1)
        )
        var visited: [Int] = []
        var receivedIteratorFailure = false

        do throws(Either<Never, Sequence.Fixture.Borrowing.IteratorFailure>) {
            _ = try source.contains { element in
                visited.append(element)
                return false
            }
        } catch {
            if case .right(.failure) = error { receivedIteratorFailure = true }
        }

        #expect(receivedIteratorFailure)
        #expect(visited == [10])
    }

    @Test
    func `borrowing contains distinguishes predicate failure`() {
        let source = Sequence.Fixture.Borrowing.FailingSource(
            [10, 20, 30],
            failAt: Cardinal(99)
        )
        var visited: [Int] = []
        var receivedPredicateFailure = false

        do throws(Either<PredicateFailure, Sequence.Fixture.Borrowing.IteratorFailure>) {
            _ = try source.contains { element throws(PredicateFailure) in
                visited.append(element)
                if element == 20 { throw .stop }
                return false
            }
        } catch {
            if case .left(.stop) = error { receivedPredicateFailure = true }
        }

        #expect(receivedPredicateFailure)
        #expect(visited == [10, 20])
    }

    @Test
    func `borrowing contains short circuits before a later iterator failure`() {
        let source = Sequence.Fixture.Borrowing.FailingSource(
            [10, 20, 30],
            failAt: Cardinal(2)
        )
        var visited: [Int] = []

        do throws(Either<Never, Sequence.Fixture.Borrowing.IteratorFailure>) {
            let result = try source.contains { element in
                visited.append(element)
                return element == 20
            }
            #expect(result)
        } catch {
            Issue.record("contains should have short-circuited; got \(error)")
        }

        #expect(visited == [10, 20])
    }
}
