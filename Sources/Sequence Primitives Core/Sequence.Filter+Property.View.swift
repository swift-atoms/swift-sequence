public import Property_Primitives

/// Property.View extensions for filter operations on `Sequence.Protocol` conformers.
///
/// - Note: Requires `Element: Copyable` because matching elements are copied
///   into the result array.
extension Property.View
where Base: Sequence.`Protocol` & ~Copyable, Base.Element: Copyable, Tag == Sequence.Filter {

    /// Filter elements: `.filter { }` → `[Element]`
    ///
    /// Returns an array containing only the elements that satisfy the predicate.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5, 6])
    /// let evens = container.filter { $0 % 2 == 0 }  // [2, 4, 6]
    /// ```
    ///
    /// - Parameter predicate: A closure that returns `true` for elements to include.
    /// - Returns: An array of elements satisfying the predicate.
    @inlinable
    public func callAsFunction(_ predicate: (Base.Element) -> Bool) -> [Base.Element] {
        var result: [Base.Element] = []
        var iterator = unsafe base.pointee.makeIterator()
        while let element = iterator.next() {
            if predicate(element) {
                result.append(element)
            }
        }
        return result
    }
}
