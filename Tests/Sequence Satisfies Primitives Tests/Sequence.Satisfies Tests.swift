import Sequence_Primitives_Test_Support
import Testing

extension Sequence.Satisfies {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

// MARK: - Unit

extension Sequence.Satisfies.Test.Unit {
    @Test
    func `satisfies all returns true when all match`() {
        var source = Sequence.Fixture.Source([2, 4, 6, 8])
        #expect(source.satisfies.all { $0 % 2 == 0 })
    }

    @Test
    func `satisfies all returns false when one fails`() {
        var source = Sequence.Fixture.Source([2, 4, 5, 8])
        #expect(!source.satisfies.all { $0 % 2 == 0 })
    }

    @Test
    func `satisfies any returns true when one matches`() {
        var source = Sequence.Fixture.Source([1, 3, 4, 7])
        #expect(source.satisfies.any { $0 % 2 == 0 })
    }

    @Test
    func `satisfies any returns false when none match`() {
        var source = Sequence.Fixture.Source([1, 3, 5, 7])
        #expect(!source.satisfies.any { $0 % 2 == 0 })
    }

    @Test
    func `satisfies none returns true when none match`() {
        var source = Sequence.Fixture.Source([1, 3, 5, 7])
        #expect(source.satisfies.none { $0 % 2 == 0 })
    }

    @Test
    func `satisfies none returns false when one matches`() {
        var source = Sequence.Fixture.Source([1, 3, 4, 7])
        #expect(!source.satisfies.none { $0 % 2 == 0 })
    }
}

// MARK: - Edge Case

extension Sequence.Satisfies.Test.`Edge Case` {
    @Test
    func `satisfies all on empty sequence returns true`() {
        var source = Sequence.Fixture.Source<Int>([])
        #expect(source.satisfies.all { _ in false })
    }

    @Test
    func `satisfies any on empty sequence returns false`() {
        var source = Sequence.Fixture.Source<Int>([])
        #expect(!source.satisfies.any { _ in true })
    }

    @Test
    func `satisfies none on empty sequence returns true`() {
        var source = Sequence.Fixture.Source<Int>([])
        #expect(source.satisfies.none { _ in true })
    }
}
