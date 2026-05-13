# Difference

@Metadata {
    @TitleHeading("Sequence Primitives")
}

Myers O(ND) diff — minimal edit scripts between two sequences, with closure-based and Equatable-based entry points.

## Overview

`Sequence.Difference` computes the minimum edit distance between two sequences using Myers' O(ND) algorithm (1986). The result is a sequence of edit steps describing how to transform the old sequence into the new one.

```swift
let changes = Sequence.Difference.diff(["a", "b", "c"], ["a", "c", "d"])
let collected = changes.collect()
// [.both("a"), .first("b"), .both("c"), .second("d")]
```

The implementation ships in `Sequence Difference Primitives` as a separate sub-target. The diff types conform to `Sequence.Protocol`, so the result composes with the lazy/terminal surface — you can `.filter { $0.isChange }`, `.reduce.into(0) { ... }`, etc.

## Two entry points

`Sequence.Difference` exposes two factory methods:

### Closure-based (`diff(oldCount:newCount:equals:)`)

The core algorithm. Takes counts and an equality closure; places zero constraints on element type:

```swift
let steps: Sequence.Difference.Steps = Sequence.Difference.diff(
    oldCount: Cardinal(UInt(old.count)),
    newCount: Cardinal(UInt(new.count)),
    equals: { oldIdx, newIdx in
        // oldIdx and newIdx are Ordinal positions into old and new
        someComparison(at: oldIdx, against: newIdx)
    }
)
```

This is the load-bearing entry point — it works on `~Copyable` containers, on `Span<T>`-backed data, on indexed sources, and on anything else where the elements aren't directly comparable but a comparison is expressible at the index level.

The result is `Sequence.Difference.Steps` — a `Sequence.Protocol` over payload-free `Sequence.Difference.Step` values (`.first`, `.second`, `.both`).

### Equatable-based (`diff(_:_:)`)

Convenience for `Array<Equatable>` inputs:

```swift
let changes = Sequence.Difference.diff(["a", "b"], ["a", "c"])
// Returns Sequence.Difference.Changes<String> with element payloads
```

The result is `Sequence.Difference.Changes<Value>` — a `Sequence.Protocol` over `Sequence.Difference.Change<Value>` values, each carrying the element payload at that step.

## Output types

| Type | What it carries | When you get it |
|------|----------------|-----------------|
| `Sequence.Difference.Steps` | A sequence of payload-free `Step` values | From the closure-based entry point. |
| `Sequence.Difference.Changes<Value>` | A sequence of element-carrying `Change<Value>` values | From the Equatable-based entry point. |
| `Sequence.Difference.Step` | `.first` / `.second` / `.both` enum | The step kind, no element payload. |
| `Sequence.Difference.Change<Element>` | `.first(Element)` / `.second(Element)` / `.both(Element)` enum | A step with its element payload. |
| `Sequence.Difference.Hunk` | A contiguous run of changes | Computed from `Changes` via `hunks(context:)` for unified-diff-style output. |

`Steps.counts()` and `Changes.counts()` both return `(removed: Cardinal, inserted: Cardinal)` — quick stats without iterating.

## Algorithm internals

The Myers algorithm operates on Int — the package's typed primitives (`Ordinal`, `Cardinal`) bridge at the entry/exit boundary. The internal `v[k + offset]` and `trace[d]` 2D array indexing doesn't benefit from typed positions; the WORKAROUND comment at the entry point names this explicitly and tracks the future migration trigger.

Time complexity is O(ND) where N is the total length and D is the edit distance — nearly linear for similar sequences (small D), quadratic worst case for completely different sequences. Space is also O(ND) for the trace array.

## Hunks for unified-diff output

`Sequence.Difference.Changes` can be grouped into hunks for unified-diff-style rendering:

```swift
let changes = Sequence.Difference.diff(oldLines, newLines)
let hunks = changes.hunks(context: Cardinal(3))
for hunk in hunks {
    print("@@ -\(hunk.oldStart),\(hunk.oldCount) +\(hunk.newStart),\(hunk.newCount) @@")
    for change in hunk.changes {
        print("\(change.marker)\(change.element)")
    }
}
```

`hunks(context:)` takes a context-line count and emits the minimum hunks needed to represent every `.first`/`.second` change with the specified context.
