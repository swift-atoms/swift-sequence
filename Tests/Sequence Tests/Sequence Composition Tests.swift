import Cardinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Sequence compositions preserve transformation order` {
        @Suite struct `No sequence composition unit cases are defined` {}
        @Suite struct `No sequence composition boundary cases are defined` {}
        @Suite struct `Composed sequence operations produce the expected ordered values` {}
    }
}

extension Sequence.`Sequence compositions preserve transformation order`.`Composed sequence operations produce the expected ordered values` {
    @Test
    func `Mapping before filtering collects the matching transformed values`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        let result =
            source
            .map { $0 * 3 }
            .filter { $0 > 10 }
            .collect()
        #expect(result == [12, 15, 18, 21, 24, 27, 30])
    }

    @Test
    func `Filtering before mapping transforms only the matching values`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result =
            source
            .filter { $0 % 2 != 0 }
            .map { $0 * $0 }
            .collect()
        #expect(result == [1, 9, 25])
    }

    @Test
    func `Dropping before taking a prefix selects the expected middle values`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6, 7, 8])
        let result =
            source
            .drop(first: Cardinal(2))
            .prefix(first: Cardinal(3))
            .collect()
        #expect(result == [3, 4, 5])
    }

    @Test
    func `Taking a prefix before mapping transforms only the retained values`() {
        let source = Sequence.Fixture.Source([10, 20, 30, 40, 50])
        let result =
            source
            .prefix(first: Cardinal(3))
            .map { $0 / 10 }
            .collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `Chained sequence maps apply transformations in order`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result =
            source
            .map { $0 + 1 }
            .map { $0 * 2 }
            .map { $0 - 1 }
            .collect()
        #expect(result == [3, 5, 7])
    }

    @Test
    func `Predicate dropping before filtering preserves the remaining matches`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6])
        let result =
            source
            .drop(while: { $0 < 3 })
            .filter { $0 % 2 == 0 }
            .collect()
        #expect(result == [4, 6])
    }

    @Test
    func `Compact mapping before taking a prefix counts only nonnil results`() {
        let source = Sequence.Fixture.Source(["1", "two", "3", "four", "5", "6"])
        let result =
            source
            .compactMap { Int($0) }
            .prefix(first: Cardinal(3))
            .collect()
        #expect(result == [1, 3, 5])
    }

    @Test
    func `Mapping before flat mapping collects the transformed inner sequences`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result =
            source
            .map { $0 * 2 }
            .flatMap { n in Sequence.Fixture.Source([n, n + 1]) }
            .collect()
        #expect(result == [2, 3, 4, 5, 6, 7])
    }

    @Test
    func `Flat mapping before filtering collects matching flattened elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result =
            source
            .flatMap { n in Sequence.Fixture.Source(Array(1...n)) }
            .filter { $0 > 1 }
            .collect()
        #expect(result == [2, 2, 3])
    }

    @Test
    func `Composed sequence transformations preserve an empty source`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result =
            source
            .map { $0 * 2 }
            .filter { $0 > 0 }
            .drop(first: .one)
            .prefix(first: Cardinal(5))
            .collect()
        #expect(result.isEmpty)
    }
}
