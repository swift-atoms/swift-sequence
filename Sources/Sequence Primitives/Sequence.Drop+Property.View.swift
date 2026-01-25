public import Property_Primitives

extension Property.View
where Base: Sequence.`Protocol` & ~Copyable, Base.Element: Copyable, Tag == Sequence.Drop {

    /// Skip first N elements: `.drop.first(_:)`
    ///
    /// Returns an array containing all elements after skipping the first `count` elements.
    /// If count >= total elements, returns empty array.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// container.drop.first(2)  // [3, 4, 5]
    /// container.drop.first(10) // []
    /// ```
    @inlinable
    public func first(_ count: Int) -> [Base.Element] {
        var result: [Base.Element] = []
        var iterator = unsafe base.pointee.makeIterator()
        var skipped = 0
        while let element = iterator.next() {
            if skipped < count {
                skipped += 1
                continue
            }
            result.append(element)
        }
        return result
    }

    /// Skip elements while predicate is true: `.drop.while { }`
    ///
    /// Returns an array containing all elements starting from the first element
    /// that does not satisfy the predicate.
    ///
    /// ```swift
    /// var container = MyContainer([1, 2, 3, 4, 5])
    /// container.drop.while { $0 < 3 }  // [3, 4, 5]
    /// ```
    @inlinable
    public func `while`(_ predicate: (Base.Element) -> Bool) -> [Base.Element] {
        var result: [Base.Element] = []
        var iterator = unsafe base.pointee.makeIterator()
        var dropping = true
        while let element = iterator.next() {
            if dropping && predicate(element) {
                continue
            }
            dropping = false
            result.append(element)
        }
        return result
    }
}
