import Iterator
import Sequence

extension Sequence {
    enum Fixture {}
}

extension Sequence.Fixture {
    struct Source<Element: Sendable>: Sequenceable, Sendable {
        let elements: [Element]

        init(_ elements: [Element]) {
            self.elements = elements
        }

        consuming func makeIterator() -> FixtureIterator<Element> {
            FixtureIterator(elements)
        }
    }
}

struct FixtureIterator<Element: Sendable>: Iterator.`Protocol` {
    var elements: [Element]
    var index: Int

    init(_ elements: [Element]) {
        self.elements = elements
        self.index = 0
    }

    mutating func next() -> Element? {
        guard index < elements.count else { return nil }
        defer { index += 1 }
        return elements[index]
    }
}
