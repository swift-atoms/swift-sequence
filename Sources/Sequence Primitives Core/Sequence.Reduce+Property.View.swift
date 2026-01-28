public import Property_Primitives

/// Property.View extensions for reduction operations on `Sequence.Protocol` conformers.
extension Property.View
where Base: Sequence.`Protocol` & ~Copyable, Tag == Sequence.Reduce {

    /// Reduce with mutable accumulator: `.reduce.into(_:) { }`
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
    public func into<Result>(
        _ initial: Result,
        _ operation: (inout Result, Base.Element) -> Void
    ) -> Result {
        var result = initial
        var iterator = unsafe base.pointee.makeIterator()
        while let element = iterator.next() {
            operation(&result, element)
        }
        return result
    }

    /// Reduce with immutable accumulator: `.reduce.from(_:) { }`
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
    public func from<Result>(
        _ initial: Result,
        _ operation: (Result, Base.Element) -> Result
    ) -> Result {
        var result = initial
        var iterator = unsafe base.pointee.makeIterator()
        while let element = iterator.next() {
            result = operation(result, element)
        }
        return result
    }
}
