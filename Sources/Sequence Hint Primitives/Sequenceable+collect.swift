public import Cardinal_Primitives
public import Cardinal_Primitives_Standard_Library_Integration

extension Sequenceable where Self: ~Copyable, Element: Copyable & Escapable {
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
    /// Uses `.hint.count` to pre-allocate the result array, avoiding
    /// repeated reallocation when the conformer provides a stored count.
    /// `Element: Copyable` is required to store elements in `Array`.
    ///
    /// - Returns: An array containing all elements of the sequence.
    @inlinable
    public consuming func collect() throws(Iterator.Failure) -> [Element] {
        let hint = self.hint.count
        var iterator = self.makeIterator()
        var result: [Element] = []
        result.reserveCapacity(hint)
        while let element = try iterator.next() {
            result.append(element)
        }
        return result
    }
}
