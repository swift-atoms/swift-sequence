public import Sequence_Primitives

// MARK: - Fixture Namespace

extension Sequence {
    /// Test fixtures for `Sequence.Protocol` and related protocols.
    public enum Fixture {}
}

// MARK: - Source

extension Sequence.Fixture {
    /// Minimal `Sequence.Protocol` conformer for testing, backed by an array.
    public struct Source<Element>: Sequence.`Protocol`, Sendable
    where Element: Sendable {
        @usableFromInline
        let _elements: [Element]

        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
        }

        @inlinable
        public consuming func makeIterator() -> Iterator {
            Iterator(_elements)
        }
    }
}

extension Sequence.Fixture.Source {
    /// Iterator for `Sequence.Fixture.Source`.
    public struct Iterator: Sequence.Iterator.`Protocol` {
        @usableFromInline
        var _elements: [Element]

        @usableFromInline
        var _index: Int

        @inlinable
        init(_ elements: [Element]) {
            self._elements = elements
            self._index = 0
        }

        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Element> {
            let remaining = _elements.count - _index
            let take = min(Int(maximumCount.rawValue), remaining)
            guard take > 0 else { return _elements.span.extracting(first: 0) }
            let start = _index
            _index += take
            return _elements.span
                .extracting(droppingFirst: start)
                .extracting(first: take)
        }

        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Element? {
            guard _index < _elements.count else { return nil }
            defer { _index += 1 }
            return _elements[_index]
        }
    }
}

// MARK: - Clearable Source

extension Sequence.Fixture {
    /// `Sequence.Clearable` conformer for testing consuming iteration via `forEach.consuming`.
    public struct ClearableSource<Element>: Sequence.`Protocol`, Sequence.`Clearable`, Sendable
    where Element: Sendable {
        @usableFromInline
        var _elements: [Element]

        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
        }

        @inlinable
        public consuming func makeIterator() -> Source<Element>.Iterator {
            .init(_elements)
        }

        @inlinable
        public mutating func removeAll() {
            _elements.removeAll()
        }
    }
}

// MARK: - Drainable Source

extension Sequence.Fixture {
    /// `Sequence.Drain.Protocol` conformer for testing drain operations.
    public struct DrainableSource<Element>: Sequence.Drain.`Protocol` {
        @usableFromInline
        var _elements: [Element]

        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
        }

        @inlinable
        public mutating func drain(_ body: (consuming Element) -> Void) {
            while !_elements.isEmpty {
                body(_elements.removeFirst())
            }
        }
    }
}
