# MOA / Class Projection via Generated Dispatch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the array-driven type-hierarchy walk (`_project`) that computes a drug's mode-of-action and class node with compile-time `<:` dispatch generated from a single source-of-truth list, and expose node enumeration via accessors.

**Architecture:** Keep the abstract type tree untouched. Keep one declared const list per projection level (`MOA_NODES`, `CLASS_NODES`) as the single source of truth. Generate one `mode_of_action`/`drug_class` method per node from those lists with `@eval`; Julia's most-specific `<:` dispatch then performs the ancestor walk at compile time. Expose the lists for plots via exported accessor functions.

**Tech Stack:** Julia, Test.jl. Package `AntiRheumaticDrugs.jl`. Tests run with the Julia MCP (`mcp__julia__julia_eval`), never `julia -e` in Bash.

## Global Constraints

- Run all Julia code through the Julia MCP (`mcp__julia__julia_eval`), never `julia -e` in Bash.
- Do not align `=` signs across lines with padding spaces.
- `mode_of_action`'s `error` fallback MUST be scoped to `btsDMARD`, never `DrugClass`. `csDMARD` and `Cortisone` must keep throwing `MethodError` (asserted by `test/runtests.jl`).
- Every MOA node sits in a disjoint subtree; the generated methods must not introduce dispatch ambiguity.
- Public enumeration is via accessor functions `moa_nodes()`/`class_nodes()`, not the bare consts.
- Behavior of `mode_of_action`, `drug_class`, `moa_symbol`, `class_symbol`, `count_modes_of_action`, `is_d2t` is unchanged for every registered drug.
- Source spec: `docs/superpowers/specs/2026-06-24-moa-projection-dispatch-design.md`.

---

### Task 1: Enumeration accessors

**Files:**
- Modify: `src/api.jl` (add accessors near the `MOA_NODES`/`CLASS_NODES` consts at lines 110-112)
- Modify: `src/AntiRheumaticDrugs.jl:50` (add exports)
- Test: `test/runtests.jl`

**Interfaces:**
- Consumes: existing consts `MOA_NODES`, `CLASS_NODES` (`src/api.jl:110-112`).
- Produces: `moa_nodes() -> NTuple{13,DataType}` returning `MOA_NODES`; `class_nodes() -> NTuple{4,DataType}` returning `CLASS_NODES`. Both exported.

- [ ] **Step 1: Write the failing test**

Add a new testset to `test/runtests.jl` (after the existing `@testset "level projections"` block, before the `materialization` import line at 154):

```julia
    @testset "node enumeration" begin
        @test moa_nodes() === AntiRheumaticDrugs.MOA_NODES
        @test class_nodes() === AntiRheumaticDrugs.CLASS_NODES
        @test TNFi in moa_nodes()
        @test IL12_23i in moa_nodes()
        @test Set(class_nodes()) == Set((Cortisone, csDMARD, bDMARD, tsDMARD))
        # accessors are exported (resolve without qualification)
        @test isdefined(@__MODULE__, :moa_nodes)
        @test isdefined(@__MODULE__, :class_nodes)
    end
```

- [ ] **Step 2: Run test to verify it fails**

Run via Julia MCP:
```julia
import Pkg; Pkg.activate("."); Pkg.test()
```
Expected: FAIL — `UndefVarError: moa_nodes not defined`.

- [ ] **Step 3: Write minimal implementation**

In `src/api.jl`, immediately after the `const CLASS_NODES = (...)` line (currently `src/api.jl:112`), add:

```julia
"""
    moa_nodes() -> Tuple

The tuple of all mode-of-action node types — the targets of
[`mode_of_action`](@ref). For iterating MOAs (e.g. plot facets).
"""
moa_nodes() = MOA_NODES

"""
    class_nodes() -> Tuple

The tuple of all class node types — the targets of [`drug_class`](@ref).
"""
class_nodes() = CLASS_NODES
```

In `src/AntiRheumaticDrugs.jl`, change line 50 from:
```julia
export count_modes_of_action, is_d2t
```
to:
```julia
export count_modes_of_action, is_d2t
export moa_nodes, class_nodes
```

- [ ] **Step 4: Run test to verify it passes**

Run via Julia MCP:
```julia
import Pkg; Pkg.activate("."); Pkg.test()
```
Expected: PASS — full suite green, including `node enumeration`.

- [ ] **Step 5: Commit**

```bash
git add src/api.jl src/AntiRheumaticDrugs.jl test/runtests.jl
git commit -m "feat: add moa_nodes/class_nodes enumeration accessors"
```

---

### Task 2: Full-registry projection characterization test

**Files:**
- Modify: `test/runtests.jl`

**Interfaces:**
- Consumes: `moa_nodes()`/`class_nodes()` (Task 1); existing `mode_of_action`, `drug_class`, `category`, `is_btsdmard`, `classify`, and `AntiRheumaticDrugs.REGISTRY`.
- Produces: nothing consumed downstream — this is a refactor guard. It passes against the *current* walk-based implementation and must keep passing after Task 3.

This is a characterization test: it pins current behavior across the whole registry so the Task 3 refactor cannot silently change a projection. It passes on the current code (no red phase).

- [ ] **Step 1: Write the characterization test**

Add to `test/runtests.jl`, inside the `node enumeration` testset's file region — add a new testset after it:

```julia
    @testset "projection invariants (full registry)" begin
        for d in values(AntiRheumaticDrugs.REGISTRY)
            c = category(d)
            # class projection: defined for every drug, lands on a class node
            # that is an ancestor of (or equal to) the drug's category
            dc = drug_class(d)
            @test dc in class_nodes()
            @test c <: dc
            if is_btsdmard(d)
                # MOA projection only for b/tsDMARDs
                moa = mode_of_action(d)
                @test moa in moa_nodes()
                @test c <: moa
            else
                # csDMARD / Cortisone have no MOA node
                @test_throws MethodError mode_of_action(d)
            end
        end
    end
```

- [ ] **Step 2: Run to confirm it passes on current code**

Run via Julia MCP:
```julia
import Pkg; Pkg.activate("."); Pkg.test()
```
Expected: PASS — the current `_project` walk already satisfies these invariants. (If it fails, stop: the invariants are wrong, not the code.)

- [ ] **Step 3: Commit**

```bash
git add test/runtests.jl
git commit -m "test: characterize projection invariants across full registry"
```

---

### Task 3: Replace `_project` walk with generated dispatch

**Files:**
- Modify: `src/api.jl` (remove `_project` at lines 114-122; replace `mode_of_action`/`drug_class` definitions at 124-125 and 141-142 with generated methods)
- Modify: `test/runtests.jl:136` (drop now-unused `MOA_NODES`/`CLASS_NODES` from the import)

**Interfaces:**
- Consumes: `MOA_NODES`, `CLASS_NODES` consts (`src/api.jl`), the type tree from `src/types.jl`.
- Produces: `mode_of_action(::Type{<:T})` for each `T in MOA_NODES`; `drug_class(::Type{<:T})` for each `T in CLASS_NODES`; a `btsDMARD`-scoped `mode_of_action` fallback and a `DrugClass`-scoped `drug_class` fallback (both `error`). The drug/`category` forwarders are preserved. Behavior is identical to the pre-refactor walk (guarded by Task 2 + existing `level projections` testset).

- [ ] **Step 1: Confirm the guard tests are green before refactoring**

Run via Julia MCP:
```julia
import Pkg; Pkg.activate("."); Pkg.test()
```
Expected: PASS (baseline — Tasks 1 and 2 are in).

- [ ] **Step 2: Delete the `_project` walker and the old projection definitions**

In `src/api.jl`, remove the walker (currently lines 114-122):

```julia
# walk C and its supertypes, return the first that is in `nodes`
function _project(::Type{C}, nodes) where {C<:DrugClass}
    T = C
    while T !== DrugClass
        T in nodes && return T
        T = supertype(T)
    end
    error("no level node found for $C in $nodes")
end
```

Remove the old `mode_of_action` type method (currently line 124):

```julia
mode_of_action(::Type{C}) where {C<:btsDMARD} = _project(C, MOA_NODES)
```

Remove the old `drug_class` type method (currently line 141):

```julia
drug_class(::Type{C}) where {C<:DrugClass} = _project(C, CLASS_NODES)
```

Keep the forwarders `mode_of_action(d::AntiRheumaticDrug) = mode_of_action(category(d))` (line 125) and `drug_class(x) = drug_class(category(x))` (line 142). Keep the `const MOA_NODES`/`const CLASS_NODES` lines and the `moa_nodes`/`class_nodes` accessors from Task 1.

- [ ] **Step 3: Add the generated dispatch methods**

In `src/api.jl`, where the old `mode_of_action(::Type...)` method was (just above the `mode_of_action(d::AntiRheumaticDrug)` forwarder), add:

```julia
for T in MOA_NODES
    @eval mode_of_action(::Type{<:$T}) = $T
end
# reachable only by a btsDMARD leaf missing from MOA_NODES; keeps csDMARD /
# Cortisone throwing MethodError rather than this error
mode_of_action(::Type{C}) where {C<:btsDMARD} = error("no MOA node for $C")
```

Where the old `drug_class(::Type...)` method was (just above the `drug_class(x)` forwarder), add:

```julia
for T in CLASS_NODES
    @eval drug_class(::Type{<:$T}) = $T
end
drug_class(::Type{C}) where {C<:DrugClass} = error("no class node for $C")
```

- [ ] **Step 4: Drop the unused import in tests**

In `test/runtests.jl`, change line 136 from:
```julia
    using AntiRheumaticDrugs: mode_of_action, drug_class, MOA_NODES, CLASS_NODES
```
to:
```julia
    using AntiRheumaticDrugs: mode_of_action, drug_class
```

- [ ] **Step 5: Run the full suite to verify behavior is preserved**

Run via Julia MCP:
```julia
import Pkg; Pkg.activate("."); Pkg.test()
```
Expected: PASS — `level projections`, `node enumeration`, and `projection invariants (full registry)` all green; no `_project` referenced anywhere.

- [ ] **Step 6: Verify no dangling references and run doctests**

Run via Julia MCP to confirm `_project` is gone and doctests still pass:
```julia
import Pkg; Pkg.activate("docs"); Pkg.develop(path="."); using Documenter, AntiRheumaticDrugs; doctest(AntiRheumaticDrugs)
```
Expected: doctests PASS (the `moa_symbol`/`class_symbol`/`mode_of_action` doctests in `src/api.jl` are unchanged behavior).
Also confirm via shell that no source references the removed walker:
```bash
grep -rn "_project" src/ && echo "FOUND — must be removed" || echo "clean"
```
Expected: `clean`.

- [ ] **Step 7: Commit**

```bash
git add src/api.jl test/runtests.jl
git commit -m "refactor: project MOA/class via generated dispatch, drop _project walk"
```

---

## Self-Review

**Spec coverage:**
- Generated dispatch replacing `_project` → Task 3. ✓
- Single source of truth (consts) feeding both projection + enumeration → Task 1 (accessors) + Task 3 (generation from consts). ✓
- Accessor enumeration API, exported → Task 1. ✓
- `btsDMARD`-scoped MOA fallback preserving `MethodError` for csDMARD/Cortisone → Task 3 Step 3 + Global Constraints; guarded by Task 2 + existing `level projections` tests. ✓
- Full-registry regression test → Task 2. ✓
- Test import switch off bare consts → Task 3 Step 4. ✓
- Parametric-type rejection: design decision only, no implementation task needed. ✓ (no gap)

**Placeholder scan:** No TBD/TODO/"handle edge cases"/"similar to". All code blocks complete. ✓

**Type consistency:** `moa_nodes()`/`class_nodes()` named identically in Tasks 1, 2, 3. `MOA_NODES`/`CLASS_NODES` const names consistent. `mode_of_action`/`drug_class` signatures match across tasks. Fallback scoping (`btsDMARD` for MOA, `DrugClass` for class) consistent between Global Constraints and Task 3. ✓
