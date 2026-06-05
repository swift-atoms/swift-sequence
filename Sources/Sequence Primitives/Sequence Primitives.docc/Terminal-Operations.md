# Terminal Operations

@Metadata {
    @TitleHeading("Sequence Primitives")
}

The terminal-operation surface — `count`, `contains`, `satisfies`, `reduce`, `first`, `forEach`, and the `hint` namespace — split between direct properties/methods and fluent `Property.Inout` accessors.

## Overview

Terminal operations consume a sequence and produce a result. Sequence ships six closed-algebra terminal ops plus the `hint` size-estimate namespace. The split: operations that fan out into multiple related members go through the fluent `Property.Inout` surface; operations that are single-shot live as direct properties or methods.

```swift
source.count                         // Cardinal — total element count (direct property)
source.count(where: { $0 > 0 })      // Cardinal — count matching predicate (direct method)
source.hint.count                    // Cardinal — cheap, imprecise size hint (fluent)
source.contains { $0 == target }     // Bool
source.first { $0.isPrime }          // Optional<Element>
source.satisfies.all { $0 > 0 }      // Bool — every element satisfies
source.satisfies.any { $0 > 0 }      // Bool — at least one satisfies
source.satisfies.none { $0 > 0 }     // Bool — no element satisfies
source.reduce.into(0) { $0 += $1 }   // Result — mutable accumulator
source.reduce.from(1) { $0 * $1 }    // Result — immutable accumulator
source.forEach { print($0) }         // Void — borrowing iteration
source.forEach.borrowing { ... }     // Void — explicit borrowing form
source.drain { ... }                 // Void — consuming drain (Sequence.Drain.Protocol)
```

## Why the split shape?

Terminal ops that have a **single canonical form** are direct properties (`count`) or direct methods (`count(where:)`, `contains { }`, `first { }`). Putting them under a `Property.Inout` namespace would add a level of indirection for no discoverability benefit — there's nothing else under `.count.` to surface.

Terminal ops that **fan out into multiple related members** go through the fluent `Property.Inout` surface from `swift-property-primitives`. After typing `source.satisfies.` the IDE offers `.all`, `.any`, `.none`. After typing `source.reduce.` it offers `.into(_:) { }`, `.from(_:) { }`. After typing `source.forEach.` it offers `.borrowing { }`. The fluent namespace earns its place when there's a family to surface.

The fluent mechanism is `Property<Tag, Base>.Inout`: each tag (`Sequence.Satisfies`, `Sequence.Reduce`, `Sequence.ForEach`, …) is a phantom-typed namespace enum. Extensions on `Property.Inout` parameterized by the tag attach methods to the fluent chain. The cost is one indirection per terminal call — every `Property.Inout` member is `@inlinable` so the optimizer dissolves it.

## The terminal surface

Each terminal operation either ships as direct protocol members or as a tag enum + `Property.Inout` extensions:

| Operation | Shape | Surface |
|---|---|---|
| `Sequence.Protocol.count` | Direct `var count: Cardinal` | Single canonical form — no fan-out. |
| `Sequence.Protocol.count(where:)` | Direct method | Single canonical form — predicate-taking variant of `count`. |
| `Sequence.Hint` | Tag + `.count: Cardinal` | Namespace for cheap-but-imprecise size hints (`hint.count` defaults to `.zero`; conformers override). |
| `Sequence.Contains` | Tag + `(predicate)` direct method | Any element matches? → `Bool` |
| `Sequence.First` | Tag + `(predicate)` direct method | First element matching the predicate → `Optional<Element>` |
| `Sequence.Satisfies` | Tag + `.all { }`, `.any { }`, `.none { }` | Universal / existential / negative-existential checks → `Bool` |
| `Sequence.Reduce` | Tag + `.into(_:) { }`, `.from(_:) { }` | Mutable / immutable accumulator reduction → `Result` |
| `Sequence.ForEach` | Tag + `(body)`, `.borrowing { }` | Borrowing iteration (consuming drain lives on `Sequence.Drain`) |

For tag-based operations, the `Property.Inout` entry points are uniform: each `Sequence.Protocol` conformer exposes `var <op>: Property<Sequence.X, Self>.Inout { mutating _read … mutating _modify … }` via an extension in the corresponding sub-namespace target (`Sequence ForEach`, `Sequence Satisfies`, etc.). The methods on each `Property.Inout` are constrained to the relevant tag plus any extra `Base` requirements (e.g., `Base.Element: Copyable` for predicate-taking ops).

## ForEach's two forms

`forEach` borrows; both accessor forms are non-consuming:

- **`source.forEach { body }`** — calls `body` with each element by `borrowing`. The default.
- **`source.forEach.borrowing { body }`** — same semantics, explicit name for clarity.

Consuming iteration is a separate operation: **`source.drain { body }`** (on `Sequence.Drain.Protocol`) yields each element by `consuming` and leaves the container empty. It is the canonical path for moving ownership of `~Copyable` elements out of a sequence; the container survives and can be repopulated via subsequent `append`/`insert` calls.

## `~Copyable` element handling

Predicate-taking terminal ops (`contains`, `first`, `satisfies`, `count(where:)`) constrain `Base.Element: Copyable`. The closure parameter is `borrowing Base.Element` so even Copyable elements aren't unnecessarily copied; the Copyable bound is required to spell the closure parameter at all.

`reduce` works on Copyable elements only via the standard accumulator pattern. `forEach.borrowing` works on `~Copyable` elements directly; the consuming `drain` (on `Sequence.Drain.Protocol`) safely moves `~Copyable` elements out while leaving the container empty.

A future API surface for `~Copyable`-element terminal ops (a `contains` that takes `(borrowing Base.Element) -> Bool` without the Copyable bound, etc.) is on the roadmap. The 0.1.0 surface concretizes the common case.
