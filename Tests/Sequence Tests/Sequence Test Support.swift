import Iterator
import Sequence

extension Sequence {

    enum Fixture {}
}

extension Sequence.Fixture {

    struct Source<Element>: Sequenceable, Sendable
    where Element: Sendable {
        let _elements: [Element]

        init(_ elements: [Element]) {
            self._elements = elements
        }
    }
}

extension Sequence.Fixture.Source {

    consuming func makeIterator() -> Iterator {
        Iterator(_elements)
    }
}

extension Sequence.Fixture.Source {

    struct Iterator: Iterating {
        var _elements: [Element]

        var _index: Int

        init(_ elements: [Element]) {
            self._elements = elements
            self._index = 0
        }
    }
}

extension Sequence.Fixture.Source.Iterator {

    mutating func next() -> Element? {
        guard _index < _elements.count else { return nil }
        defer { _index += 1 }
        return _elements[_index]
    }
}

extension Sequenceable where Self: ~Copyable, Element: Copyable, Iterator.Failure == Never {

    consuming func collect() -> [Element] {
        var elements: [Element] = []
        var iterator = makeIterator()
        while let element = iterator.next() {
            elements.append(element)
        }
        return elements
    }
}

extension Sequence.Fixture {

    enum Drainable {}
}

extension Sequence.Fixture.Drainable {

    struct Source<Element>: Sequence.Drain.`Protocol` {
        var _elements: [Element]

        init(_ elements: [Element]) {
            self._elements = elements
        }
    }
}

extension Sequence.Fixture.Drainable.Source {

    mutating func drain(_ body: (consuming Element) -> Void) {
        while !_elements.isEmpty {
            body(_elements.removeFirst())
        }
    }
}
