public import Index_Primitives
public import Property_Primitives

/// Property.Inout extensions for counting operations on `Sequence.Protocol` conformers.
extension Property.Inout
where Base: Sequence.`Protocol`, Base.Element: Copyable, Tag == Sequence.Count {

    /// Count elements matching predicate via `.count.where { }`.
    ///
    /// Returns the number of elements satisfying the predicate.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5, 6])
    /// let evenCount = container.count.where { $0 % 2 == 0 }  // Cardinal(3)
    /// ```
    ///
    /// - Parameter predicate: A closure that returns `true` for elements to count.
    /// - Returns: The count of matching elements.
    @inlinable
    public func `where`(_ predicate: (borrowing Base.Element) -> Bool) -> Cardinal {
        var count = Cardinal.zero
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            if predicate(element) { count += .one }
        }
        return count
    }

    /// Count all elements via `.count.all`.
    ///
    /// Returns the total number of elements in the sequence.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// let total = container.count.all  // Cardinal(5)
    /// ```
    @inlinable
    public var all: Cardinal {
        var count = Cardinal.zero
        var iterator = base.value.makeIterator()
        while iterator.next() != nil { count += .one }
        return count
    }
}
