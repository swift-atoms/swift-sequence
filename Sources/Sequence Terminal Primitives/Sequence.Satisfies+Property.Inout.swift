public import Property_Primitives

/// Property.Inout extensions for predicate satisfaction checks on `Sequence.Protocol` conformers.
extension Property.Inout
where Base: Sequence.`Protocol`, Base.Element: Copyable, Tag == Sequence.Satisfies {

    /// Check if all elements satisfy predicate via `.satisfies.all { }`.
    ///
    /// Returns `true` if every element in the sequence satisfies the predicate,
    /// or if the sequence is empty.
    ///
    /// ```swift
    /// var container = MyContainer([2, 4, 6])
    /// container.satisfies.all { $0 % 2 == 0 }  // true
    /// ```
    ///
    /// - Parameter predicate: A closure that takes an element and returns a Bool.
    /// - Returns: `true` if all elements satisfy the predicate.
    @inlinable
    public func all(_ predicate: (borrowing Base.Element) -> Bool) -> Bool {
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            if !predicate(element) { return false }
        }
        return true
    }

    /// Check if any element satisfies predicate via `.satisfies.any { }`.
    ///
    /// Returns `true` if at least one element satisfies the predicate.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3])
    /// container.satisfies.any { $0 % 2 == 0 }  // true (2 is even)
    /// ```
    ///
    /// - Parameter predicate: A closure that takes an element and returns a Bool.
    /// - Returns: `true` if any element satisfies the predicate.
    @inlinable
    public func any(_ predicate: (borrowing Base.Element) -> Bool) -> Bool {
        var iterator = base.value.makeIterator()
        while let element = iterator.next() {
            if predicate(element) { return true }
        }
        return false
    }

    /// Check if no elements satisfy predicate via `.satisfies.none { }`.
    ///
    /// Returns `true` if no element satisfies the predicate,
    /// or if the sequence is empty.
    ///
    /// ```swift
    /// var container = MyContainer([1, 3, 5])
    /// container.satisfies.none { $0 % 2 == 0 }  // true (no evens)
    /// ```
    ///
    /// - Parameter predicate: A closure that takes an element and returns a Bool.
    /// - Returns: `true` if no elements satisfy the predicate.
    @inlinable
    public func none(_ predicate: (borrowing Base.Element) -> Bool) -> Bool {
        !any(predicate)
    }
}
