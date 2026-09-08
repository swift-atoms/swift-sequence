import Sequence
import Sequence_Test_Support
import Testing

@Suite
struct `Collecting a sequence preserves every element in order` {
    @Suite struct `Sequence collection materializes ordered elements` {}
    @Suite struct `Sequence collection preserves empty and singleton sources` {}
    @Suite struct `No sequence collection integration cases are defined` {}
}

extension `Collecting a sequence preserves every element in order`.`Sequence collection materializes ordered elements` {
    @Test
    func `collect materializes sequence into array`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5])
        let result = source.collect()
        #expect(result == [1, 2, 3, 4, 5])
    }

    @Test
    func `collect preserves element order`() {
        let source = Sequence.Fixture.Source([5, 3, 1, 4, 2])
        let result = source.collect()
        #expect(result == [5, 3, 1, 4, 2])
    }
}

extension `Collecting a sequence preserves every element in order`.`Sequence collection preserves empty and singleton sources` {
    @Test
    func `collect on empty sequence returns empty array`() {
        let source = Sequence.Fixture.Source<Int>([])
        let result = source.collect()
        #expect(result.isEmpty)
    }

    @Test
    func `Collecting a singleton sequence preserves its sole element`() {
        let source = Sequence.Fixture.Source([42])
        let result = source.collect()
        #expect(result == [42])
    }
}
