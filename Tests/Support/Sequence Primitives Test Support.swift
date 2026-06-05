public import Sequence_Primitives

// MARK: - Fixture Namespace

extension Sequence {
    /// Test fixtures for `Sequence.Protocol` and related protocols.
    public enum Fixture {}
}

// MARK: - Source

extension Sequence.Fixture {
    /// Minimal `Sequence.Protocol` conformer for testing, backed by an array.
    public struct Source<Element>: Sequenceable, Sendable
    where Element: Sendable {
        @usableFromInline
        let _elements: [Element]

        /// Creates a fixture source from a copy of the provided elements.
        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
        }
    }
}

extension Sequence.Fixture.Source {
    /// Creates a fresh iterator over the fixture elements.
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(_elements)
    }
}

extension Sequence.Fixture.Source {
    /// Iterator for `Sequence.Fixture.Source`.
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
    /// Returns the next fixture element, or `nil` when iteration completes.
    @inlinable
    public mutating func next() -> Element? {
        guard _index < _elements.count else { return nil }
        defer { _index += 1 }
        return _elements[_index]
    }
}

// MARK: - Drainable.Source

extension Sequence.Fixture {
    /// Namespace for `Sequence.Drain.Protocol`-conforming fixtures.
    public enum Drainable {}
}

extension Sequence.Fixture.Drainable {
    /// `Sequence.Drain.Protocol` conformer for testing drain operations.
    public struct Source<Element>: Sequence.Drain.`Protocol` {
        @usableFromInline
        var _elements: [Element]

        /// Creates a drainable fixture source from a copy of the provided elements.
        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
        }
    }
}

extension Sequence.Fixture.Drainable.Source {
    /// Drains every fixture element through the closure (ownership transferred per element).
    @inlinable
    public mutating func drain(_ body: (consuming Element) -> Void) {
        while !_elements.isEmpty {
            body(_elements.removeFirst())
        }
    }
}
