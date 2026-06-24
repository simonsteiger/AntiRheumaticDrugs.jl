# MOA / class projection via generated dispatch

**Date:** 2026-06-24
**Status:** approved design, pre-implementation

## Problem

Determining a drug's mode-of-action (MOA) node and class node walks the type
hierarchy from the leaf upward until it hits a "marked" node. The marked nodes
live in two hand-maintained tuples, `MOA_NODES` and `CLASS_NODES` (`src/api.jl`),
consumed by a runtime-style walk, `_project` (`src/api.jl:115-122`).

Pain points (priority order):

1. **Elegance** — `_project`'s `while` loop + `error()` fallback is un-Julian;
   dispatch should do this.
2. **Extensibility** — adding a new projection *level* (a 3rd tier) means another
   array + another bespoke walker.
3. **Access** — grabbing "the MOA ancestor of a drug" is fine, but the design
   couples projection to a structure that is awkward to also use for enumeration.
4. **Maintenance (bonus)** — the tuples are a parallel structure that can drift
   from the type tree; forgetting to add a node yields a runtime `error`, not a
   compile-time signal.

Parametric abstract types (e.g. `AbstractMOA{T}`) were considered and rejected:
projection level is *determined by* the type, not a free-varying parameter, so a
type parameter only re-encodes information already available via `category` and
still requires computing the ancestor. The correct tool is per-type
dispatch/traits. The one legitimate parameter, `AntiRheumaticDrug{C}`, already
exists and is unchanged.

## Constraint: enumeration is required

Plots will need the *set* of MOA nodes (and class nodes) to iterate over. The
tree cannot derive this set structurally — "MOA node" is a semantic mark, not a
tree leaf (`TNFi` is a direct `bDMARD` child; `IL6i` is a grandchild under
`ILi`). A declared list of nodes must therefore exist regardless.

Conclusion: keep a single declared list per level as the **single source of
truth**, and generate the projection methods *from* that list. One source feeds
both projection and enumeration, so they cannot drift.

## Design

Type tree in `src/types.jl` is unchanged.

In `src/api.jl`, replace the `MOA_NODES`/`CLASS_NODES` + `_project` +
hand-written `mode_of_action`/`drug_class` walkers with generated dispatch:

```julia
const MOA_NODES =
    (TNFi, CD20i, IFNi, CD28i, BAFFi, JAKi, PDE4i,
     IL1i, IL5i, IL6i, IL17i, IL23i, IL12_23i)
const CLASS_NODES = (Cortisone, csDMARD, bDMARD, tsDMARD)

for T in MOA_NODES
    @eval mode_of_action(::Type{<:$T}) = $T
end
# btsDMARD-scoped fallback ONLY (see behavior preservation below)
mode_of_action(::Type{C}) where {C<:btsDMARD} = error("no MOA node for $C")

for T in CLASS_NODES
    @eval drug_class(::Type{<:$T}) = $T
end
drug_class(::Type{C}) where {C<:DrugClass} = error("no class node for $C")
```

Julia's most-specific `<:` dispatch performs the walk at compile time: every MOA
node sits in a disjoint subtree, so each concrete leaf matches exactly one
generated method (no ambiguity — verified). The drug/`category` forwarders
(`mode_of_action(d) = mode_of_action(category(d))`, etc.) are unchanged.

`MOA_NODES`/`CLASS_NODES` remain as unexported internal consts (the source of
truth). Enumeration is exposed through accessors.

### Enumeration API (accessors, per decision)

```julia
moa_nodes()   = MOA_NODES
class_nodes() = CLASS_NODES
```

Exported from `src/AntiRheumaticDrugs.jl` (added to the existing export list).
Accessors (not the bare consts) are public so the internal representation can
change later without breaking callers.

## Behavior preservation (must stay green)

- `mode_of_action`, `drug_class`, `moa_symbol`, `class_symbol`,
  `count_modes_of_action`, `is_d2t` return identical results for every
  registered drug.
- **`mode_of_action` fallback is `btsDMARD`-scoped, not `DrugClass`-scoped.**
  `csDMARD` and `Cortisone` must continue to throw `MethodError` (asserted by
  `test/runtests.jl:151-152`). A `DrugClass`-wide fallback would convert those to
  `ErrorException` and break the tests. The generated MOA methods cover only
  `btsDMARD` leaves; the `error()` fallback is reachable only by a `btsDMARD`
  leaf missing from `MOA_NODES`, matching the old `_project` error.
- `drug_class` is defined for all `DrugClass` subtypes (`Cortisone`, `csDMARD`,
  `bDMARD`, `tsDMARD` cover every subtree); its `error()` fallback is
  unreachable in normal use. No test expects a `MethodError` here.

## Test changes

- `test/runtests.jl:136` imports `MOA_NODES`/`CLASS_NODES` directly. Switch the
  import to the public accessors `moa_nodes`/`class_nodes` and update the call
  sites.
- Add a regression test: for every drug in the registry, assert
  `mode_of_action`/`drug_class` returns the same value as before the refactor
  (guards the disjointness/dispatch claim across the full tree).

## Out of scope

- Macro-per-node co-location (would give declaration next to each type def plus
  auto-registration, at the cost of a macro to maintain). Revisit only if the
  taxonomy grows enough that the central lists become a burden.
- Adding new projection levels or drug classes (the new shape makes this a
  one-block addition, but no such level is added here).
