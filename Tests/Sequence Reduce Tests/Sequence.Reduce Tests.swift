import Cardinal
import Either
import Sequence_Reduce
import Sequence_Test_Support
import Testing

extension Sequence.Reduce {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.Reduce.Test.Unit {
    @Test
    func `borrowing reduce accumulates without copying the source`() {
        let source = Sequence.Fixture.Borrowing.Source([1, 2, 3, 4])
        let result = source.reduce(into: 0) {
            (result: inout Int, element: borrowing Int) throws(Never) in
            result += element
        }
        #expect(result == 10)
    }

    @Test
    func `reduce into accumulates with mutable state`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let sum = source.reduce.into(0) { $0 += $1 }
        #expect(sum == 15)
    }

    @Test
    func `reduce from accumulates with immutable folding`() {
        var source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let product = source.reduce.from(1) { $0 * $1 }
        #expect(product == 120)
    }

    @Test
    func `reduce into builds collection`() {
        var source = Sequence.Fixture.Source([1, 2, 3])
        let strings = source.reduce.into([String]()) { $0.append(String($1)) }
        #expect(strings == ["1", "2", "3"])
    }
}

extension Sequence.Reduce.Test.`Edge Case` {
    @Test
    func `reduce into on empty sequence returns initial`() {
        var source = Sequence.Fixture.Source<Int>([])
        let result = source.reduce.into(42) { $0 += $1 }
        #expect(result == 42)
    }

    @Test
    func `reduce from on empty sequence returns initial`() {
        var source = Sequence.Fixture.Source<Int>([])
        let result = source.reduce.from(99) { $0 + $1 }
        #expect(result == 99)
    }
}

extension Sequence.Reduce.Test.Integration {

    enum AccumulatorFailure: Swift.Error {
        case stop
    }

    @Test
    func `borrowing reduce distinguishes iterator failure and stops`() {
        let source = Sequence.Fixture.Borrowing.FailingSource(
            [10, 20, 30],
            failAt: Cardinal(2)
        )
        var visited: [Int] = []
        var receivedIteratorFailure = false

        do throws(Either<Never, Sequence.Fixture.Borrowing.IteratorFailure>) {
            _ = try source.reduce(into: 0) { result, element in
                visited.append(copy element)
                result += element
            }
        } catch {
            if case .right(.failure) = error { receivedIteratorFailure = true }
        }

        #expect(receivedIteratorFailure)
        #expect(visited == [10, 20])
    }

    @Test
    func `borrowing reduce distinguishes callback failure and short circuits`() {
        let source = Sequence.Fixture.Borrowing.FailingSource(
            [10, 20, 30],
            failAt: Cardinal(99)
        )
        var visited: [Int] = []
        var receivedCallbackFailure = false

        do throws(Either<AccumulatorFailure, Sequence.Fixture.Borrowing.IteratorFailure>) {
            _ = try source.reduce(into: 0) {
                (result: inout Int, element: borrowing Int) throws(AccumulatorFailure) in
                visited.append(copy element)
                if element == 20 { throw .stop }
                result += element
            }
        } catch {
            if case .left(.stop) = error { receivedCallbackFailure = true }
        }

        #expect(receivedCallbackFailure)
        #expect(visited == [10, 20])
    }
}
