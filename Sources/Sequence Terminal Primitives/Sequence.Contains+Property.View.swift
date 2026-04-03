public import Property_Primitives

/// Property.View extensions for containment checks on `Sequence.Protocol` conformers.
extension Property.View
where Base: Sequence.`Protocol`, Base.Element: Copyable, Tag == Sequence.Contains {

    /// Check if sequence contains element matching predicate: `.contains { }`
    ///
    /// Returns `true` if at least one element satisfies the predicate.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// container.contains { $0 == 3 }  // true
    /// container.contains { $0 > 10 }  // false
    /// ```
    ///
    /// - Parameter predicate: A closure that takes an element and returns a Bool.
    /// - Returns: `true` if any element satisfies the predicate.
    @inlinable
    public func callAsFunction(_ predicate: (borrowing Base.Element) -> Bool) -> Bool {
        var iterator = unsafe base.pointee.makeIterator()
        while let element = iterator.next() {
            if predicate(element) { return true }
        }
        return false
    }
}
