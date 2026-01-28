public import Property_Primitives
public import Index_Primitives

extension Property.View
where Base: Sequence.`Protocol` & ~Copyable, Base.Element: Copyable, Tag == Sequence.Prefix {

    /// Take first N elements: `.prefix.first(_:)`
    ///
    /// Returns an array containing the first `count` elements.
    /// If count >= total elements, returns all elements.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// container.prefix.first(Cardinal(3))  // [1, 2, 3]
    /// container.prefix.first(Cardinal(10)) // [1, 2, 3, 4, 5]
    /// ```
    @inlinable
    public func first(_ count: Cardinal) -> [Base.Element] {
        var result: [Base.Element] = []
        var iterator = unsafe base.pointee.makeIterator()
        var taken = Cardinal.zero
        while taken < count, let element = iterator.next() {
            result.append(element)
            taken += .one
        }
        return result
    }

    /// Take elements while predicate is true: `.prefix.while { }`
    ///
    /// Returns an array containing elements from the start while they satisfy
    /// the predicate. Stops at the first element that doesn't satisfy it.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// container.prefix.while { $0 < 4 }  // [1, 2, 3]
    /// ```
    @inlinable
    public func `while`(_ predicate: (Base.Element) -> Bool) -> [Base.Element] {
        var result: [Base.Element] = []
        var iterator = unsafe base.pointee.makeIterator()
        while let element = iterator.next() {
            if !predicate(element) { break }
            result.append(element)
        }
        return result
    }
}
