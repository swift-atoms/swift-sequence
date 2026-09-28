import Either
import Iterator
import Sequence
import Testing

private enum SourceError: Swift.Error, Equatable {
    case failed
}

private enum BodyError: Swift.Error, Equatable {
    case rejected
}

private typealias FailingIterator = Iterator.Witness<Int, SourceError>

private struct FailingSequence: Sequenceable {

    let elements: [Int]
    let failureIndex: Int?

    consuming func makeIterator() -> FailingIterator {
        var index = 0
        return FailingIterator { () throws(SourceError) -> Int? in
            if index == failureIndex { throw SourceError.failed }
            guard index < elements.count else { return nil }
            defer { index += 1 }
            return elements[index]
        }
    }
}

@Suite
struct `Sequence Either Tests` {

    @Test
    func `forEach visits every element`() throws {
        let sequence = FailingSequence(elements: [1, 2, 3], failureIndex: nil)
        var visited: [Int] = []

        try sequence.forEach { (element: Int) throws(BodyError) in
            visited.append(element)
        }

        #expect(visited == [1, 2, 3])
    }

    @Test
    func `forEach wraps body failure on the left`() {
        let sequence = FailingSequence(elements: [1, 2, 3], failureIndex: nil)

        do throws(Either<BodyError, SourceError>) {
            try sequence.forEach { (element: Int) throws(BodyError) in
                if element == 2 { throw .rejected }
            }
            Issue.record("expected body failure")
        } catch {
            guard case .left(let failure) = error else {
                Issue.record("expected left body failure")
                return
            }
            #expect(failure == .rejected)
        }
    }

    @Test
    func `forEach wraps iterator failure on the right`() {
        let sequence = FailingSequence(elements: [1, 2, 3], failureIndex: 1)

        do throws(Either<BodyError, SourceError>) {
            try sequence.forEach { (_: Int) throws(BodyError) in }
            Issue.record("expected iterator failure")
        } catch {
            guard case .right(let failure) = error else {
                Issue.record("expected right iterator failure")
                return
            }
            #expect(failure == .failed)
        }
    }

    @Test
    func `consume preserves iterator failure`() {
        let sequence = FailingSequence(elements: [1, 2, 3], failureIndex: 2)

        do throws(Either<BodyError, SourceError>) {
            try sequence.consume { (_: consuming Int) throws(BodyError) in }
            Issue.record("expected iterator failure")
        } catch {
            guard case .right(let failure) = error else {
                Issue.record("expected right iterator failure")
                return
            }
            #expect(failure == .failed)
        }
    }
}
