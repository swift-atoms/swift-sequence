import Iterator_Protocol
import Sequence

extension Sequence {

    public enum Fixture {}
}

extension Sequence.Fixture {

    public struct Source<Element>: Sequenceable, Sendable
    where Element: Sendable {
        @usableFromInline
        let _elements: [Element]

        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
        }
    }
}

extension Sequence.Fixture.Source {

    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_elements)
    }
}

extension Sequence.Fixture.Source {

    public struct Iterator: Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        var _elements: [Element]

        @usableFromInline
        var _index: Int

        @inlinable
        package init(_ elements: [Element]) {
            self._elements = elements
            self._index = 0
        }
    }
}

extension Sequence.Fixture.Source.Iterator {

    @inlinable
    public mutating func next() -> Element? {
        guard _index < _elements.count else { return nil }
        defer { _index += 1 }
        return _elements[_index]
    }
}

extension Sequence.Fixture {

    public enum Drainable {}
}

extension Sequence.Fixture.Drainable {

    public struct Source<Element>: Sequence.Drain.`Protocol` {
        @usableFromInline
        var _elements: [Element]

        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
        }
    }
}

extension Sequence.Fixture.Drainable.Source {

    @inlinable
    public mutating func drain(_ body: (consuming Element) -> Void) {
        while !_elements.isEmpty {
            body(_elements.removeFirst())
        }
    }
}
