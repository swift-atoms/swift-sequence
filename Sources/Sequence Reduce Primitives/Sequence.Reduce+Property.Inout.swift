public import Property_Primitives

/// Property.Inout extensions for reduction operations on `Sequence.Protocol` conformers.
extension Property.Inout
where
    Base: Sequenceable,
    Base.Element: Copyable,
    Base.Iterator.Failure == Never,
    Tag == Sequence.Reduce
{

    /// Reduce with mutable accumulator via `.reduce.into(_:) { }`.
    ///
    /// Combines elements using a mutable accumulator for better performance
    /// with value types.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// let sum = container.reduce.into(0) { $0 += $1 }  // 15
    /// ```
    ///
    /// - Parameters:
    ///   - initial: The initial accumulator value.
    ///   - operation: A closure that mutates the accumulator with each element.
    /// - Returns: The final accumulated value.
    @inlinable
    public func into<Accumulator>(
        _ initial: Accumulator,
        _ operation: (inout Accumulator, borrowing Base.Element) -> Void
    ) -> Accumulator {
        var result = initial
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            operation(&result, element)
        }
        return result
    }

    /// Reduce with immutable accumulator via `.reduce.from(_:) { }`.
    ///
    /// Combines elements by producing a new value at each step.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// let product = container.reduce.from(1) { $0 * $1 }  // 120
    /// ```
    ///
    /// - Parameters:
    ///   - initial: The initial value.
    ///   - operation: A closure that combines accumulator and element.
    /// - Returns: The final combined value.
    @inlinable
    public func from<Accumulator>(
        _ initial: Accumulator,
        _ operation: (Accumulator, borrowing Base.Element) -> Accumulator
    ) -> Accumulator {
        var result = initial
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            result = operation(result, element)
        }
        return result
    }
}
