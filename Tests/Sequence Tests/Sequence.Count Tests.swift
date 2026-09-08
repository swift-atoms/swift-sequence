import Cardinal
import Sequence
import Sequence_Test_Support
import Testing

extension Sequence {
    @Suite
    struct `Sequence counting reports the number of matching elements` {
        @Suite struct `Sequence counting includes exactly the matching elements` {}
        @Suite struct `Sequence counting handles predicates matching none or all elements` {}
    }
}

extension Sequence.`Sequence counting reports the number of matching elements`.`Sequence counting includes exactly the matching elements` {
    @Test
    func `count(where:) returns matching count`() {
        let source = Sequence.Fixture.Source([1, 2, 3, 4, 5, 6])
        let evens = source.count { $0 % 2 == 0 }
        #expect(evens == 3)
    }
}

extension Sequence.`Sequence counting reports the number of matching elements`.`Sequence counting handles predicates matching none or all elements` {
    @Test
    func `count(where:) with no matches returns zero`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        #expect(source.count { $0 > 100 } == Cardinal(0))
    }

    @Test
    func `count(where:) with all matching returns total`() {
        let source = Sequence.Fixture.Source([1, 2, 3])
        #expect(source.count { _ in true } == 3)
    }
}
