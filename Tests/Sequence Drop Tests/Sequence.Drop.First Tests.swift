import Cardinal
import Cardinal_Carrier
import Sequence_Drop
import Sequence_Hint
import Sequence_Test_Support
import Testing

extension Sequence.Drop {
    @Suite
    struct `First Test` {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Sequence.Drop.`First Test`.Unit {
    @Test
    func `drop first N elements`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.drop(first: Cardinal(2)).collect()
        #expect(result == [3, 4, 5])
    }

    @Test
    func `drop first 1 element`() {
        let source = Sequence.Fixture.Source([10, 20, 30])
        let result = source.drop(first: .one).collect()
        #expect(result == [20, 30])
    }
}

extension Sequence.Drop.`First Test`.`Edge Case` {
    @Test
    func `drop zero elements returns all`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(first: .zero).collect()
        #expect(result == [1, 2, 3])
    }

    @Test
    func `drop more than count returns empty`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(first: Cardinal(10)).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `drop from empty sequence`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.drop(first: Cardinal(5)).collect()
        #expect(result.isEmpty)
    }

    @Test
    func `drop exactly count returns empty`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        let result = source.drop(first: Cardinal(3)).collect()
        #expect(result.isEmpty)
    }
}
