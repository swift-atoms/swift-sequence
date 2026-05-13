public import Index_Primitives
public import Property_Primitives

/// Property.Inout extensions for span-based borrowing iteration.
///
/// > Note: Property.Inout requires `Base: Escapable` due to a fundamental
/// > language constraint (`Builtin.load` requires `Escapable`). Types that
/// > are truly `~Escapable` must use `Sequence.Borrowing.Protocol` directly.
extension Property.Inout
where
    Base: Sequence.Borrowing.`Protocol` & ~Copyable,
    Tag == Sequence.Span
{
    /// Process each span batch via `.span.forEach { }`.
    ///
    /// Iterates over spans, calling the body with each batch.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// container.span.forEach { span in
    ///     print("Batch of \(span.count) elements")
    /// }
    /// ```
    ///
    /// - Parameter body: A closure called with each span batch.
    @inlinable
    public func forEach(_ body: (Swift.Span<Base.Element>) -> Void) {
        func loop(_ source: borrowing Base) {
            var iterator = source.makeIterator()
            while true {
                let span = iterator.nextSpan(maximumCount: .max)
                if span.isEmpty { break }
                body(span)
            }
        }
        loop(base.value)
    }

    /// Process each element from spans via `.span.elements { }`.
    ///
    /// Iterates over all elements by processing spans.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3])
    /// container.span.elements { element in
    ///     print(element)  // 1, 2, 3
    /// }
    /// ```
    ///
    /// - Parameter body: A closure called with each element.
    @inlinable
    public func elements(_ body: (borrowing Base.Element) -> Void) {
        func loop(_ source: borrowing Base) {
            var iterator = source.makeIterator()
            while true {
                let span = iterator.nextSpan(maximumCount: .max)
                if span.isEmpty { break }
                for i in span.indices {
                    body(span[i])
                }
            }
        }
        loop(base.value)
    }

    /// Reduce with mutable accumulator via `.span.reduceInto(_:) { }`.
    ///
    /// Combines spans using a mutable accumulator.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// let sum = container.span.reduceInto(0) { acc, span in
    ///     for i in span.indices { acc += span[i] }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - initial: The initial accumulator value.
    ///   - operation: A closure that mutates the accumulator with each span.
    /// - Returns: The final accumulated value.
    @inlinable
    public func reduceInto<Result>(
        _ initial: Result,
        _ operation: (inout Result, Swift.Span<Base.Element>) -> Void
    ) -> Result {
        var result = initial
        func loop(_ source: borrowing Base) {
            var iterator = source.makeIterator()
            while true {
                let span = iterator.nextSpan(maximumCount: .max)
                if span.isEmpty { break }
                operation(&result, span)
            }
        }
        loop(base.value)
        return result
    }

    /// Reduce with immutable accumulator via `.span.reduceFrom(_:) { }`.
    ///
    /// Combines spans by producing a new value at each step.
    ///
    /// ```swift
    /// var container = MyContainer([[1, 2], [3, 4]])
    /// let flattened = container.span.reduceFrom([]) { acc, span in
    ///     acc + Array(span)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - initial: The initial value.
    ///   - operation: A closure that combines accumulator and span.
    /// - Returns: The final combined value.
    @inlinable
    public func reduceFrom<Result>(
        _ initial: Result,
        _ operation: (Result, Swift.Span<Base.Element>) -> Result
    ) -> Result {
        var result = initial
        func loop(_ source: borrowing Base) {
            var iterator = source.makeIterator()
            while true {
                let span = iterator.nextSpan(maximumCount: .max)
                if span.isEmpty { break }
                result = operation(result, span)
            }
        }
        loop(base.value)
        return result
    }
}
