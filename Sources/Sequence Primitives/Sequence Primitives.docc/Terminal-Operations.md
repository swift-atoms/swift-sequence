# Terminal Operations

@Metadata {
    @TitleHeading("Sequence Primitives")
}

The fluent `.<op>` accessor surface — `count`, `contains`, `satisfies`, `reduce`, `first`, `forEach` — built on `Property<Tag, Base>.Inout`.

## Overview

Terminal operations consume a sequence and produce a result. Sequence ships six closed-algebra terminal ops, each surfaced through the fluent `Property<Tag, Base>.Inout` mechanism from `swift-property-primitives`:

```swift
source.count.all                     // Cardinal — total element count
source.count.where { $0 > 0 }        // Cardinal — count matching predicate
source.contains { $0 == target }     // Bool
source.first { $0.isPrime }          // Optional<Element>
source.satisfies.all { $0 > 0 }      // Bool — every element satisfies
source.satisfies.any { $0 > 0 }      // Bool — at least one satisfies
source.satisfies.none { $0 > 0 }     // Bool — no element satisfies
source.reduce.into(0) { $0 += $1 }   // Result — mutable accumulator
source.reduce.from(1) { $0 * $1 }    // Result — immutable accumulator
source.forEach { print($0) }         // Void — borrowing iteration
source.forEach.borrowing { ... }     // Void — explicit borrowing form
source.forEach.consuming { ... }     // Void — drains a Clearable
```

## Why the `.<op>` shape?

Two options for naming terminal ops were considered:

- **Method-on-Protocol form** (`source.count()`, `source.contains { }`, etc.) — closer to stdlib's idiom.
- **Property.Inout form** (`source.count.all`, `source.contains { }`) — what shipped.

The Property.Inout form earned its place because it makes the operation **family** discoverable at the call site. After typing `source.count.` the IDE offers `.all`, `.where { }`, and any future count-related accessor. After typing `source.satisfies.` the IDE offers `.all`, `.any`, `.none`. The single-method form forces consumers to remember each method name flat against the protocol surface.

The mechanism is `Property<Tag, Base>.Inout` from `swift-property-primitives`: each tag (`Sequence.Count`, `Sequence.Contains`, `Sequence.First`, …) is a phantom-typed namespace enum. Extensions on `Property.Inout` parameterized by the tag attach methods to the fluent chain. The cost is one indirection per terminal call — every Property.Inout member is `@inlinable` so the optimizer dissolves it.

## The six tags

Each terminal operation has a tag enum that plays a triple role: file namespace, type namespace for the `Sequence.X` form, and phantom parameter for `Property<Sequence.X, Self>.Inout`:

| Tag | Property.Inout surface | What it does |
|-----|------------------------|--------------|
| `Sequence.Count` | `.all`, `.where { }` | Total count or predicate-matching count → `Cardinal` |
| `Sequence.Contains` | `(predicate)` | Any element matches? → `Bool` |
| `Sequence.First` | `(predicate)` | First element matching the predicate → `Optional<Element>` |
| `Sequence.Satisfies` | `.all { }`, `.any { }`, `.none { }` | Universal / existential / negative-existential checks → `Bool` |
| `Sequence.Reduce` | `.into(_:) { }`, `.from(_:) { }` | Mutable / immutable accumulator reduction → `Result` |
| `Sequence.ForEach` | `(body)`, `.borrowing { }`, `.consuming { }` | Iteration with optional explicit ownership |

The Property.Inout entry points are uniform: each `Sequence.Protocol` conformer exposes `var <op>: Property<Sequence.X, Self>.Inout { mutating _read … mutating _modify … }` via an extension in `Sequence Terminal Primitives`. The methods on each `Property.Inout` are constrained to the relevant tag plus any extra `Base` requirements (e.g., `Base.Element: Copyable` for predicate-taking ops).

## ForEach's three forms

`forEach` is the one terminal op with three accessor forms:

- **`source.forEach { body }`** — calls `body` with each element by `borrowing`. The default.
- **`source.forEach.borrowing { body }`** — same semantics, explicit name for clarity.
- **`source.forEach.consuming { body }`** — drains the sequence by `consuming` each element. Requires `Base: Sequence.Clearable`. The sequence survives but is empty.

The consuming form is intended for moving ownership of `~Copyable` elements out of a sequence. The container itself isn't destroyed — its `removeAll()` runs after every element is yielded — so it can be repopulated via subsequent `append`/`insert` calls.

## `~Copyable` element handling

Predicate-taking terminal ops (`contains`, `first`, `satisfies`, `count.where`) constrain `Base.Element: Copyable`. The closure parameter is `borrowing Base.Element` so even Copyable elements aren't unnecessarily copied; the Copyable bound is required to spell the closure parameter at all.

`reduce` works on Copyable elements only via the standard accumulator pattern. `forEach.borrowing` works on `~Copyable` elements directly; the consuming form additionally requires `Base: Sequence.Clearable` so the container can be safely drained.

A future API surface for `~Copyable`-element terminal ops (a `contains` that takes `(borrowing Base.Element) -> Bool` without the Copyable bound, etc.) is on the roadmap. The 0.1.0 surface concretizes the common case.
