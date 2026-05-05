public import Property_Primitives

/// Property.Inout extensions for draining iteration on `Sequence.Drain.Protocol` conformers.
extension Property.Inout
where Base: Sequence.Drain.`Protocol` & ~Copyable, Tag == Sequence.Drain {

    /// Draining iteration: `.drain { }`
    ///
    /// Removes all elements from the container, passing each to the closure.
    /// The container survives but is empty after this call.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3])
    /// container.drain { print($0) }  // prints 1, 2, 3
    /// // container is now empty but still usable
    /// container.append(4)  // OK
    /// ```
    ///
    /// - Parameter body: A closure called with each element (ownership transferred).
    /// - Complexity: O(n) where n is the number of elements.
    @inlinable
    public mutating func callAsFunction(_ body: (consuming Base.Element) -> Void) {
        base.value.drain(body)
    }
}
