extension Sequence.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {
    /// Materializes the sequence into an array.
    ///
    /// Terminal operation — consumes the sequence and collects all
    /// elements into an `Array`. Typical usage at the end of a lazy
    /// pipeline:
    ///
    /// ```swift
    /// let result = source.map { $0 * 2 }.filter { $0 > 5 }.collect()
    /// ```
    ///
    /// `Element: Copyable` is required to store elements in `Array`.
    ///
    /// - Returns: An array containing all elements of the sequence.
    @inlinable
    public consuming func collect() -> [Element] {
        var iterator = makeIterator()
        var result: [Element] = []
        while let element = iterator.next() {
            result.append(element)
        }
        return result
    }
}
