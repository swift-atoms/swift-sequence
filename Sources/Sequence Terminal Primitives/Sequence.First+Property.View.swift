public import Property_Primitives

/// Property.View extensions for finding first matching element on `Sequence.Protocol` conformers.
extension Property.View
where Base: Sequence.`Protocol`, Base.Element: Copyable, Tag == Sequence.First {

    /// Find first element matching predicate: `.first { }`
    ///
    /// Returns the first element that satisfies the predicate, or `nil` if none found.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// container.first { $0 % 2 == 0 }  // Optional(2)
    /// container.first { $0 > 10 }      // nil
    /// ```
    ///
    /// - Parameter predicate: A closure that takes an element and returns a Bool.
    /// - Returns: The first matching element, or `nil`.
    @inlinable
    public func callAsFunction(_ predicate: (borrowing Base.Element) -> Bool) -> Base.Element? {
        var iterator = unsafe base.value.makeIterator()
        while let element = iterator.next() {
            if predicate(element) { return element }
        }
        return nil
    }
}
