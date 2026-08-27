import Sequence
import Testing

extension Sequence {
    @Suite
    struct `Map.Flat Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.`Map.Flat Test`.Unit {
    @Test
    func `flatMap transforms and flattens`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.flatMap { n in
            Sequence.Fixture.Source(Array(repeating: n, count: n))
        }.collect()
        #expect(result == [1, 2, 2, 3, 3, 3])
    }

    @Test
    func `flatMap changes element type`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.flatMap { n in
            Sequence.Fixture.Source(["\(n)", "\(n * 10)"])
        }.collect()
        #expect(result == ["1", "10", "2", "20", "3", "30"])
    }

    @Test
    func `flatMap chains with other operations`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result =
            source
            .flatMap { n in Sequence.Fixture.Source([n, n * 10]) }
            .filter { $0 > 5 }
            .collect()
        #expect(result == [10, 20, 30])
    }

    @Test
    func `flatMap after map`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result =
            source
            .map { $0 * 2 }
            .flatMap { n in Sequence.Fixture.Source([n, n + 1]) }
            .collect()
        #expect(result == [2, 3, 4, 5, 6, 7])
    }
}

extension Sequence.`Map.Flat Test`.`Edge Case` {
    @Test
    func `flatMap over empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.flatMap { n in
            Sequence.Fixture.Source([n])
        }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `flatMap with empty inner sequences`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.flatMap { _ in
            Sequence.Fixture.Source<Int>([])
        }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `flatMap with mixed empty and non-empty inners`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4])
        let result = source.flatMap { n in
            n % 2 == 0
                ? Sequence.Fixture.Source([n, n * 10])
                : Sequence.Fixture.Source<Int>([])
        }.collect()
        #expect(result == [2, 20, 4, 40])
    }

    @Test
    func `flatMap single element outer`() {
        let source = Sequence.Fixture.Source([42])
        let result = source.flatMap { n in
            Sequence.Fixture.Source([n, n + 1, n + 2])
        }.collect()
        #expect(result == [42, 43, 44])
    }

    @Test
    func `flatMap single element inners`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.flatMap { n in
            Sequence.Fixture.Source([n * 100])
        }.collect()
        #expect(result == [100, 200, 300])
    }
}
