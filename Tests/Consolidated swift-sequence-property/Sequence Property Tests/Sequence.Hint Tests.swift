import Cardinal
import Iterator
import Ownership
import Property
import Sequence
import Testing

@Suite("Sequence.Hint × Property")
struct Sequence_Hint_Property_Tests {

    @Test
    func `default hint is a zero lower bound`() {
        var source = Sequence.Fixture.Source([1, 2, 3])

        #expect(source.hint.count == Cardinal(0))
    }
}
