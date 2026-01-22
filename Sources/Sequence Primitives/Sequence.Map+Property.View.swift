public import Property_Primitives

/// Property.View extensions for map transformation on `Sequence.Protocol` conformers.
extension Property.View
where Base: Sequence.`Protocol` & ~Copyable, Tag == Sequence.Map {

    /// Transform elements: `.map { }` → `[U]`
    ///
    /// Returns an array containing the results of mapping the given closure
    /// over the sequence's elements.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3])
    /// let doubled = container.map { $0 * 2 }        // [2, 4, 6]
    /// let strings = container.map { "\($0)" }       // ["1", "2", "3"]
    /// ```
    ///
    /// - Parameter transform: A closure that transforms an element.
    /// - Returns: An array of transformed elements.
    @inlinable
    public func callAsFunction<U>(_ transform: (Base.Element) -> U) -> [U] {
        var result: [U] = []
        var iterator = unsafe base.pointee.makeIterator()
        while let element = iterator.next() {
            result.append(transform(element))
        }
        return result
    }
}
