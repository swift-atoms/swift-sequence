public import Cardinal
public import Carrier_Protocol
public import Iterator_Chunk
public import Iterator_Protocol
public import Sequence
public import Sequence_Borrowing
public import Sequence_Drain
public import Sequence_Protocol

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

    public struct Iterator: Iterator::Iterator.`Protocol` {
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

    public enum Borrowing {}
}

extension Sequence.Fixture.Borrowing {

    public struct Source<Element: Copyable>: Sequence.Borrowing.`Protocol` {
        @usableFromInline
        let _elements: [Element]

        @inlinable
        public init(_ elements: [Element]) {
            self._elements = elements
        }

        @inlinable
        @_lifetime(borrow self)
        public borrowing func makeIterator() -> Iterator::Iterator.Chunk<Element> {
            Iterator::Iterator.Chunk(_elements.span)
        }
    }
}

extension Sequence.Fixture.Borrowing {

    public enum IteratorFailure: Swift.Error, Equatable {
        case failure
    }

    public struct FailingSource<Element: Copyable>: Sequence.Borrowing.`Protocol` {
        @usableFromInline
        let _elements: [Element]

        @usableFromInline
        let _failAt: Cardinal::Cardinal

        @inlinable
        public init(_ elements: [Element], failAt: Cardinal::Cardinal) {
            self._elements = elements
            self._failAt = failAt
        }

        @inlinable
        @_lifetime(borrow self)
        public borrowing func makeIterator() -> FailingIterator<Element> {
            FailingIterator(_elements.span, failAt: _failAt)
        }
    }

    public struct FailingIterator<Element: Copyable>: ~Escapable {
        @usableFromInline
        let _span: Swift.Span<Element>

        @usableFromInline
        let _failAt: Cardinal::Cardinal

        @usableFromInline
        var _position: Int

        @inlinable
        @_lifetime(copy span)
        package init(_ span: Swift.Span<Element>, failAt: Cardinal::Cardinal) {
            self._span = span
            self._failAt = failAt
            self._position = 0
        }
    }
}

extension Sequence.Fixture.Borrowing.FailingIterator: Iterator::Iterator.Chunk.`Protocol` {

    public typealias Failure = Sequence.Fixture.Borrowing.IteratorFailure

    @inlinable
    @_lifetime(&self)
    public mutating func next(
        maximumCount _: some Carrier::Carrier.`Protocol`<Cardinal::Cardinal>
    ) throws(Failure) -> Swift.Span<Element> {
        if Cardinal::Cardinal(UInt(_position)) == _failAt { throw .failure }
        guard _position < _span.count else { return _span.extracting(first: 0) }
        let result = _span.extracting(droppingFirst: _position).extracting(first: 1)
        _position += 1
        return result
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
