import Cardinal
import Either
import Sequence_First
import Sequence_Test_Support
import Testing

extension Sequence.First {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.First.Test.Unit {
    @Test
    func `borrowing first returns the first match`() {
        let source = Sequence.Fixture.Borrowing.Source([1, 2, 3, 4])
        let result = source.first { element throws(Never) in element > 2 }
        #expect(result == 3)
    }

    @Test
    func `first matching element found`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.first { $0 > 3 }
        #expect(result == 4)
    }

    @Test
    func `first returns earliest match`() {
        var source = Sequence.Fixture.Source([10, 20, 30, 40])
        let result = source.first { $0 % 2 == 0 }
        #expect(result == 10)
    }
}

extension Sequence.First.Test.`Edge Case` {
    @Test
    func `first with no match returns nil`() {
        var source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.first { $0 > 100 }
        #expect(result == nil)
    }

    @Test
    func `first on empty sequence returns nil`() {
        var source = Sequence.Fixture.Source<Int>([])
        let result = source.first { _ in true }
        #expect(result == nil)
    }
}

extension Sequence.First.Test.Integration {

    enum PredicateFailure: Swift.Error {
        case stop
    }

    @Test
    func `borrowing first distinguishes iterator failure`() {
        let source = Sequence.Fixture.Borrowing.FailingSource(
            [10, 20, 30],
            failAt: Cardinal(1)
        )
        var receivedIteratorFailure = false

        do throws(Either<Never, Sequence.Fixture.Borrowing.IteratorFailure>) {
            _ = try source.first { _ in false }
        } catch {
            if case .right(.failure) = error { receivedIteratorFailure = true }
        }

        #expect(receivedIteratorFailure)
    }

    @Test
    func `borrowing first distinguishes predicate failure`() {
        let source = Sequence.Fixture.Borrowing.FailingSource(
            [10, 20, 30],
            failAt: Cardinal(99)
        )
        var visited: [Int] = []
        var receivedPredicateFailure = false

        do throws(Either<PredicateFailure, Sequence.Fixture.Borrowing.IteratorFailure>) {
            _ = try source.first { element throws(PredicateFailure) in
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
    func `borrowing first short circuits before a later iterator failure`() {
        let source = Sequence.Fixture.Borrowing.FailingSource(
            [10, 20, 30],
            failAt: Cardinal(2)
        )
        var visited: [Int] = []

        do throws(Either<Never, Sequence.Fixture.Borrowing.IteratorFailure>) {
            let result = try source.first { element in
                visited.append(element)
                return element == 20
            }
            #expect(result == 20)
        } catch {
            Issue.record("first should have short-circuited; got \(error)")
        }

        #expect(visited == [10, 20])
    }
}
