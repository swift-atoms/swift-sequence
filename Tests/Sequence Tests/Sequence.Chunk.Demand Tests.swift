import Cardinal
import Iterator
import Sequence
import Testing

private final class SequenceDemandLog {
    var requests: [Cardinal] = []
    var scalarCalls = 0
    var predicates: [Int] = []
}

private enum SequenceDemandFailure: Swift.Error, Equatable {
    case unavailable
}

private struct BorrowedDemandSequence: Sequenceable, ~Copyable, ~Escapable {
    typealias Element = Int
    typealias Iterator = BorrowedDemandIterator

    let values: Swift.Span<Int>
    let log: SequenceDemandLog
    let fails: Bool

    @_lifetime(copy values)
    init(_ values: Swift.Span<Int>, log: SequenceDemandLog, fails: Bool = false) {
        self.values = values
        self.log = log
        self.fails = fails
    }

    @_lifetime(copy self)
    consuming func makeIterator() -> Iterator {
        Iterator(values, log: log, fails: fails)
    }
}

private struct BorrowedDemandIterator:
    Iterator::Iterator.`Protocol`, __IteratorChunkProtocol, ~Copyable, ~Escapable
{
    typealias Element = Int
    typealias Failure = SequenceDemandFailure

    let values: Swift.Span<Int>
    let log: SequenceDemandLog
    let fails: Bool
    var position = 0

    @_lifetime(copy values)
    init(_ values: Swift.Span<Int>, log: SequenceDemandLog, fails: Bool) {
        self.values = values
        self.log = log
        self.fails = fails
    }

    mutating func next() throws(Failure) -> Int? {
        log.scalarCalls += 1
        if fails { throw .unavailable }
        guard position < values.count else { return nil }
        defer { position += 1 }
        return values[position]
    }

    @_lifetime(&self)
    mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Failure) -> Swift.Span<Int> {
        let maximumCount = maximumCount.underlying
        log.requests.append(maximumCount)
        guard maximumCount > .zero else { return Swift.Span<Int>() }
        if fails { throw .unavailable }
        let take = Int(Swift.min(maximumCount.rawValue, UInt(values.count - position)))
        let start = position
        position += take
        return values.extracting(start..<position)
    }
}

private func checkZeroDemand<I: __IteratorChunkProtocol & ~Copyable & ~Escapable>(
    _ iterator: inout I,
    log: SequenceDemandLog
) throws(SequenceDemandFailure)
where I.Element == Int, I.Failure == SequenceDemandFailure {
    let requests = log.requests
    let predicates = log.predicates
    let scalarCalls = log.scalarCalls

    let isEmpty = try iterator.next(maximumCount: Cardinal.zero).isEmpty
    #expect(isEmpty)
    let skipped = try iterator.skip(by: Cardinal.zero)
    #expect(skipped == .zero)
    #expect(log.requests == requests)
    #expect(log.predicates == predicates)
    #expect(log.scalarCalls == scalarCalls)
}

private func checkChunkDemand<S: Sequenceable & ~Copyable & ~Escapable>(
    _ sequence: consuming S,
    expected: [Int],
    maximumCount: UInt,
    log: SequenceDemandLog
) throws(SequenceDemandFailure)
where
    S.Element == Int,
    S.Iterator: __IteratorChunkProtocol,
    S.Iterator.Failure == SequenceDemandFailure
{
    var iterator = sequence.makeIterator()
    var actual: [Int] = []
    var exhausted = false

    for _ in 0...expected.count {
        try checkZeroDemand(&iterator, log: log)
        let chunk = try iterator.next(maximumCount: Cardinal(maximumCount))
        let count = chunk.count
        #expect(UInt(count) <= maximumCount)
        for index in chunk.indices { actual.append(chunk[index]) }
        if count == 0 {
            exhausted = true
            break
        }
    }

    #expect(exhausted)
    #expect(actual == expected)
    try checkZeroDemand(&iterator, log: log)
}

private func checkScalarValues<S: Sequenceable & ~Copyable & ~Escapable>(
    _ sequence: consuming S,
    expected: [Int]
) throws(SequenceDemandFailure)
where S.Element == Int, S.Iterator.Failure == SequenceDemandFailure {
    var iterator = sequence.makeIterator()
    var actual: [Int] = []
    while let value = try iterator.next() { actual.append(value) }
    #expect(actual == expected)
}

private func checkDemandFailure<S: Sequenceable & ~Copyable & ~Escapable>(
    _ sequence: consuming S,
    log: SequenceDemandLog
) throws(SequenceDemandFailure)
where
    S.Element == Int,
    S.Iterator: __IteratorChunkProtocol,
    S.Iterator.Failure == SequenceDemandFailure
{
    var iterator = sequence.makeIterator()
    try checkZeroDemand(&iterator, log: log)
    #expect(log.requests.isEmpty)

    do throws(SequenceDemandFailure) {
        _ = try iterator.next(maximumCount: Cardinal.one)
        Issue.record("A positive request must surface the source failure")
    } catch {
        #expect(error == .unavailable)
    }
    #expect(log.requests.count == 1)
    #expect(log.requests.first != .zero)
    #expect(log.predicates.isEmpty)
    try checkZeroDemand(&iterator, log: log)
}

@Suite
struct `Zero chunk demand preserves sequence adapters and their borrowed sources` {
    @Test(arguments: [UInt(1), 3, UInt.max])
    func `Zero requests preserve a count based drop`(maximumCount: UInt) throws {
        let values = [1, 2, 3, 4]
        let log = SequenceDemandLog()
        try checkChunkDemand(
            BorrowedDemandSequence(values.span, log: log).drop(first: 2),
            expected: [3, 4], maximumCount: maximumCount, log: log
        )
        try checkScalarValues(
            BorrowedDemandSequence(values.span, log: SequenceDemandLog()).drop(first: 2),
            expected: [3, 4]
        )
    }

    @Test(arguments: [UInt(1), 3, UInt.max])
    func `Zero requests preserve a predicate based drop`(maximumCount: UInt) throws {
        let values = [1, 2, 3, 4]
        let log = SequenceDemandLog()
        try checkChunkDemand(
            BorrowedDemandSequence(values.span, log: log).drop(while: {
                log.predicates.append($0)
                return $0 < 3
            }),
            expected: [3, 4], maximumCount: maximumCount, log: log
        )
        #expect(log.predicates == [1, 2, 3])
        try checkScalarValues(
            BorrowedDemandSequence(values.span, log: SequenceDemandLog()).drop(while: { $0 < 3 }),
            expected: [3, 4]
        )
    }

    @Test(arguments: [UInt(1), 3, UInt.max])
    func `Zero requests preserve a count based prefix`(maximumCount: UInt) throws {
        let values = [1, 2, 3, 4]
        let log = SequenceDemandLog()
        try checkChunkDemand(
            BorrowedDemandSequence(values.span, log: log).prefix(first: 2),
            expected: [1, 2], maximumCount: maximumCount, log: log
        )
        try checkScalarValues(
            BorrowedDemandSequence(values.span, log: SequenceDemandLog()).prefix(first: 2),
            expected: [1, 2]
        )
    }

    @Test(arguments: [UInt(1), 3, UInt.max])
    func `Zero requests preserve a predicate based prefix`(maximumCount: UInt) throws {
        let values = [1, 2, 3, 4]
        let log = SequenceDemandLog()
        try checkChunkDemand(
            BorrowedDemandSequence(values.span, log: log).prefix(while: {
                log.predicates.append($0)
                return $0 < 3
            }),
            expected: [1, 2], maximumCount: maximumCount, log: log
        )
        #expect(log.predicates == [1, 2, 3])
        try checkScalarValues(
            BorrowedDemandSequence(values.span, log: SequenceDemandLog()).prefix(while: { $0 < 3 }),
            expected: [1, 2]
        )
    }

    @Test
    func `Zero requests defer every adapter source failure until positive demand`() throws {
        let values = [1, 2, 3]
        let dropCountLog = SequenceDemandLog()
        try checkDemandFailure(
            BorrowedDemandSequence(values.span, log: dropCountLog, fails: true).drop(first: 2),
            log: dropCountLog
        )
        let prefixCountLog = SequenceDemandLog()
        try checkDemandFailure(
            BorrowedDemandSequence(values.span, log: prefixCountLog, fails: true).prefix(first: 2),
            log: prefixCountLog
        )
        let dropPredicateLog = SequenceDemandLog()
        try checkDemandFailure(
            BorrowedDemandSequence(values.span, log: dropPredicateLog, fails: true).drop(while: {
                dropPredicateLog.predicates.append($0)
                return true
            }),
            log: dropPredicateLog
        )
        let prefixPredicateLog = SequenceDemandLog()
        try checkDemandFailure(
            BorrowedDemandSequence(values.span, log: prefixPredicateLog, fails: true).prefix(while: {
                prefixPredicateLog.predicates.append($0)
                return true
            }),
            log: prefixPredicateLog
        )
    }

    @Test
    func `An empty outer prefix does not evaluate an inner predicate drop`() throws {
        let values = [1, 2, 3, 4]
        let log = SequenceDemandLog()
        var iterator = BorrowedDemandSequence(values.span, log: log)
            .drop(while: {
                log.predicates.append($0)
                return $0 < 3
            })
            .prefix(first: .zero)
            .makeIterator()

        let isEmpty = try iterator.next(maximumCount: Cardinal.one).isEmpty
        #expect(isEmpty)
        #expect(log.requests.isEmpty)
        #expect(log.predicates.isEmpty)
        #expect(log.scalarCalls == 0)
        try checkZeroDemand(&iterator, log: log)
    }

    @Test
    func `An empty outer prefix does not advance nested drops and prefixes`() throws {
        let values = [1, 2, 3, 4]
        let log = SequenceDemandLog()
        var iterator = BorrowedDemandSequence(values.span, log: log)
            .prefix(while: {
                log.predicates.append($0)
                return $0 < 4
            })
            .drop(first: .one)
            .prefix(first: .zero)
            .makeIterator()

        let isEmpty = try iterator.next(maximumCount: Cardinal.one).isEmpty
        #expect(isEmpty)
        #expect(log.requests.isEmpty)
        #expect(log.predicates.isEmpty)
        #expect(log.scalarCalls == 0)
        try checkZeroDemand(&iterator, log: log)
    }

    @Test
    func `Zero requests preserve the values of a nonempty adapter composition`() throws {
        let values = [1, 2, 3, 4]
        let log = SequenceDemandLog()
        try checkChunkDemand(
            BorrowedDemandSequence(values.span, log: log)
                .drop(first: .one)
                .prefix(while: {
                    log.predicates.append($0)
                    return $0 < 4
                })
                .prefix(first: 2),
            expected: [2, 3], maximumCount: 1, log: log
        )
        #expect(log.predicates == [2, 3])
    }
}

@Suite
struct `Zero chunk demand preserves span iterator positions` {
    @Test
    func `A span iterator preserves its remaining elements across zero demand`() {
        let values = [10, 20, 30]
        var iterator = Swift.Span<Int>.Iterator(span: values.span)
        let initialIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(initialIsEmpty)
        #expect(iterator.remaining == 3)
        #expect(iterator.skip(by: Cardinal.zero) == .zero)
        #expect(iterator.next() == 10)
        let middleIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(middleIsEmpty)
        #expect(iterator.remaining == 2)
        do {
            let tail = iterator.next(maximumCount: Cardinal.max)
            var actual: [Int] = []
            for index in tail.indices { actual.append(tail[index]) }
            #expect(actual == [20, 30])
        }
        let finalIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(finalIsEmpty)
        #expect(iterator.remaining == .zero)
        #expect(iterator.next() == nil)
    }

    @Test
    func `A span batch iterator preserves its remaining elements across zero demand`() {
        let values = [10, 20, 30]
        var iterator = Swift.Span<Int>.Iterator.Batch(span: values.span)
        let initialIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(initialIsEmpty)
        #expect(iterator.remaining == 3)
        #expect(iterator.skip(by: Cardinal.zero) == .zero)
        #expect(iterator.next() == 10)
        let middleIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(middleIsEmpty)
        #expect(iterator.remaining == 2)
        do {
            let tail = iterator.next(maximumCount: Cardinal.max)
            var actual: [Int] = []
            for index in tail.indices { actual.append(tail[index]) }
            #expect(actual == [20, 30])
        }
        let finalIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(finalIsEmpty)
        #expect(iterator.remaining == .zero)
        #expect(iterator.skip(by: Cardinal.zero) == .zero)
        #expect(iterator.next() == nil)
    }
}
