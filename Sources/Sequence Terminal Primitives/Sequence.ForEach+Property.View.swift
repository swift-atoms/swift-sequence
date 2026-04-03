public import Property_Primitives

/// Property.View extensions for borrowing iteration on `Sequence.Protocol` conformers.
extension Property.View
where Base: Sequence.`Protocol`, Base.Element: Copyable, Tag == Sequence.ForEach {

    /// Borrowing iteration: `.forEach { }`
    ///
    /// Iterates over all elements without consuming the sequence.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3])
    /// container.forEach { print($0) }
    /// // container still has 3 elements
    /// ```
    ///
    /// - Parameter body: A closure called with each element.
    @inlinable
    public func callAsFunction(_ body: (borrowing Base.Element) -> Void) {
        borrowing(body)
    }

    /// Explicit borrowing iteration: `.forEach.borrowing { }`
    ///
    /// Same as `callAsFunction`, but with explicit naming for clarity.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3])
    /// container.forEach.borrowing { print($0) }
    /// // container still has 3 elements
    /// ```
    ///
    /// - Parameter body: A closure called with each element.
    @inlinable
    public func borrowing(_ body: (borrowing Base.Element) -> Void) {
        var iterator = unsafe base.pointee.makeIterator()
        while let element = iterator.next() {
            body(element)
        }
    }
}

/// Property.View extensions for consuming iteration on `Sequence.Clearable` conformers.
extension Property.View
where Base: Sequence.Clearable, Base.Element: Copyable, Tag == Sequence.ForEach {

    /// Consuming iteration: `.forEach.consuming { }`
    ///
    /// Iterates over all elements and then clears the sequence.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3])
    /// container.forEach.consuming { print($0) }
    /// // container is now empty
    /// ```
    ///
    /// - Parameter body: A closure called with each element.
    @inlinable
    public mutating func consuming(_ body: (consuming Base.Element) -> Void) {
        var iterator = unsafe base.pointee.makeIterator()
        while let element = iterator.next() {
            body(element)
        }
        unsafe base.pointee.removeAll()
    }
}
