public import Index_Primitives

extension Sequenceable where Self: ~Copyable, Element: Copyable {
    /// The number of elements matching the predicate.
    ///
    /// Eagerly consumes the sequence and returns the count of elements
    /// for which `predicate` returns `true`. O(n) in sequence length.
    ///
    /// The eager total-count default (`var count: Cardinal { consuming
    /// get }`) was relocated to `Collection.\`Protocol\`` as
    /// `var count: Index<Element>.Count { borrowing get }` per
    /// `swift-institute/Research/2026-05-22-sequence-protocol-count-relocation-impact.md`
    /// (RECOMMENDATION Option a). For multi-pass indexed storage,
    /// count belongs on Collection; for filter-count over a single-pass
    /// sequence, this method remains the canonical surface.
    ///
    /// - Parameter predicate: A closure returning `true` for elements to
    ///   count.
    /// - Returns: The count of matching elements.
    /// - Throws: `Iterator.Failure` if advancing the underlying iterator fails.
    @inlinable
    public consuming func count(
        where predicate: (borrowing Element) -> Bool
    ) throws(Iterator.Failure) -> Cardinal {
        var count = Cardinal.zero
        var iterator = self.makeIterator()
        while let element = try iterator.next() {
            if predicate(element) { count += .one }
        }
        return count
    }
}
