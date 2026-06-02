// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Cardinal_Primitives
public import Ordinal_Primitives

extension Swift.Span where Element: Copyable {
    /// Accesses the element at the given ordinal position.
    ///
    /// Bridges the typed `Ordinal` position to the stdlib `Int`-based subscript.
    ///
    /// - Parameter position: The ordinal position of the element.
    /// - Returns: The element at the given position.
    @inlinable
    @_lifetime(copy self)
    public subscript(position: Ordinal) -> Element {
        self[Int(bitPattern: position)]
    }
}

extension Swift.Span {
    /// Returns a span over the first `count` elements.
    ///
    /// Bridges the typed `Cardinal` count to the stdlib `extracting(first:)` method.
    ///
    /// - Parameter count: The number of elements to extract.
    /// - Returns: A span over the first `count` elements.
    @inlinable
    @_lifetime(copy self)
    public func extracting(first count: Cardinal) -> Self {
        self.extracting(first: Int(bitPattern: count))
    }

    /// Returns a span with the first `count` elements removed.
    ///
    /// Bridges the typed `Cardinal` count to the stdlib `extracting(droppingFirst:)` method.
    ///
    /// - Parameter count: The number of elements to drop.
    /// - Returns: A span with the first `count` elements removed.
    @inlinable
    @_lifetime(copy self)
    public func extracting(droppingFirst count: Cardinal) -> Self {
        self.extracting(droppingFirst: Int(bitPattern: count))
    }
}
