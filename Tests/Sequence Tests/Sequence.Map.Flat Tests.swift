import Sequence
import Sequence_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Flat mapping preserves outer and inner sequence order` {
        @Suite struct `Flat mapping transforms flattens and composes sequence elements` {}
        @Suite struct `Flat mapping preserves empty and singleton sequence shapes` {}
        @Suite struct `No sequence flat mapping integration cases are defined` {}
    }
}

extension Sequence.`Flat mapping preserves outer and inner sequence order`.`Flat mapping transforms flattens and composes sequence elements` {
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
    func `Flat mapping after mapping preserves the transformed inner element order`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result =
            source
            .map { $0 * 2 }
            .flatMap { n in Sequence.Fixture.Source([n, n + 1]) }
            .collect()
        #expect(result == [2, 3, 4, 5, 6, 7])
    }
}

extension Sequence.`Flat mapping preserves outer and inner sequence order`.`Flat mapping preserves empty and singleton sequence shapes` {
    @Test
    func `Flat mapping preserves an empty outer sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.flatMap { n in
            Sequence.Fixture.Source([n])
        }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `Flat mapping discards empty inner sequences`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.flatMap { _ in
            Sequence.Fixture.Source<Int>([])
        }.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `Flat mapping preserves nonempty inner elements among empty sequences`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4])
        let result = source.flatMap { n in
            n % 2 == 0
                ? Sequence.Fixture.Source([n, n * 10])
                : Sequence.Fixture.Source<Int>([])
        }.collect()
        #expect(result == [2, 20, 4, 40])
    }

    @Test
    func `Flat mapping a singleton outer sequence yields its inner elements`() {
        let source = Sequence.Fixture.Source([42])
        let result = source.flatMap { n in
            Sequence.Fixture.Source([n, n + 1, n + 2])
        }.collect()
        #expect(result == [42, 43, 44])
    }

    @Test
    func `Flat mapping singleton inner sequences preserves their outer order`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.flatMap { n in
            Sequence.Fixture.Source([n * 100])
        }.collect()
        #expect(result == [100, 200, 300])
    }
}
