"""
    classify(atc::AbstractString) -> AntiRheumaticDrug

Look up the registered drug for an ATC code. Throws `KeyError` if the code is not
registered — use [`try_classify`](@ref) for a `nothing`-returning variant, or
[`is_registered`](@ref) to test first. Legacy (pre-WHO-revision) ATC codes are
registered as aliases of their current code.

# Examples
```jldoctest
julia> substance(classify("L04AB04"))
"Adalimumab"

julia> moa_symbol(classify("L04AB04"))
:TNFi
```
"""
classify(atc::AbstractString)::AntiRheumaticDrug = REGISTRY[atc]

"""
    try_classify(atc::AbstractString) -> Union{AntiRheumaticDrug,Nothing}

Like [`classify`](@ref) but returns `nothing` for an unregistered code instead of
throwing.

# Examples
```jldoctest
julia> isnothing(try_classify("NOT_A_CODE"))
true
```
"""
try_classify(atc::AbstractString) = get(REGISTRY, atc, nothing)

"""
    is_registered(atc::AbstractString) -> Bool

`true` if `atc` is present in the registry. See [`classify`](@ref).

# Examples
```jldoctest
julia> is_registered("L04AB04"), is_registered("NOT_A_CODE")
(true, false)
```
"""
is_registered(atc::AbstractString) = haskey(REGISTRY, atc)

"""
    drug_of(d::AntiRheumaticDrug) -> AntiRheumaticDrug

Identity accessor returning the drug itself — a hook so treatment/window code can
call `drug_of` uniformly across wrapper types.
"""
drug_of(d::AntiRheumaticDrug) = d

"""
    route_of(d::AntiRheumaticDrug) -> AbstractRoute

The administration [`AbstractRoute`](@ref) of `d`.

# Examples
```jldoctest
julia> route_of(classify("D07AC01"))
Topical()
```
"""
route_of(d::AntiRheumaticDrug) = d.route

import DrugInterface:
    substance, mode_of_action, is_csdmard, is_bdmard, is_tsdmard, is_cortisone

"""
    is_class(x, T::Type{<:DrugClass}) -> Bool

`true` if `x`'s [`category`](@ref) is a subtype of `T`. The generic engine behind
the class predicates [`is_cortisone`](@ref), [`is_csdmard`](@ref),
[`is_bdmard`](@ref), and [`is_tsdmard`](@ref).

# Examples
```jldoctest
julia> is_class(classify("L04AB04"), bDMARD)   # adalimumab is a TNFi <: bDMARD
true

julia> is_class(classify("L04AF01"), bDMARD)   # tofacitinib is a JAKi <: tsDMARD
false
```
"""
is_class(x, ::Type{T}) where {T<:DrugClass} = category(x) <: T

# primitive interface methods on the concrete registry type:
is_cortisone(d::AntiRheumaticDrug) = is_class(d, Cortisone)
is_csdmard(d::AntiRheumaticDrug) = is_class(d, csDMARD)
is_bdmard(d::AntiRheumaticDrug) = is_class(d, bDMARD)
is_tsdmard(d::AntiRheumaticDrug) = is_class(d, tsDMARD)

substance(d::AntiRheumaticDrug) = d.name

"""
    is_systemic(x) -> Bool

`true` if `x`'s [`route_of`](@ref) is [`Systemic`](@ref).

# Examples
```jldoctest
julia> is_systemic(classify("L04AB04")), is_systemic(classify("D07AC01"))
(true, false)
```
"""
is_systemic(x) = route_of(x) isa Systemic

const MOA_NODES =
    (JAKi, PDE4i, TNFi, CD20i, IFNi, CD28i, BAFFi, IL1i, IL5i, IL6i, IL17i, IL23i, IL12_23i)
const CLASS_NODES = (Cortisone, csDMARD, bDMARD, tsDMARD)

# walk C and its supertypes, return the first that is in `nodes`
function _project(::Type{C}, nodes) where {C<:DrugClass}
    T = C
    while T !== DrugClass
        T in nodes && return T
        T = supertype(T)
    end
    error("no level node found for $C in $nodes")
end

mode_of_action(::Type{C}) where {C<:btsDMARD} = _project(C, MOA_NODES)
mode_of_action(d::AntiRheumaticDrug) = mode_of_action(category(d))

"""
    drug_class(x) -> Type{<:DrugClass}

Project `x` (an [`AntiRheumaticDrug`](@ref) or a `Type{<:DrugClass}`) onto its
coarse *class* node — one of [`Cortisone`](@ref), [`csDMARD`](@ref),
[`bDMARD`](@ref), [`tsDMARD`](@ref). See [`class_symbol`](@ref) for the `Symbol`
form, or [`mode_of_action`](@ref) for the finer node.

# Examples
```jldoctest
julia> class_symbol(classify("L04AB04"))   # drug_class is bDMARD
:bDMARD
```
"""
drug_class(::Type{C}) where {C<:DrugClass} = _project(C, CLASS_NODES)
drug_class(x) = drug_class(category(x))

"""
    label(T::Type) -> Symbol

`Symbol(nameof(T))` — the bare type name as a `Symbol`. Underlies
[`moa_symbol`](@ref) and [`class_symbol`](@ref).

# Examples
```jldoctest
julia> label(TNFi)
:TNFi
```
"""
label(::Type{T}) where {T} = Symbol(nameof(T))

const _PRETTY = Dict{DataType,String}(IL12_23i => "IL-12/23")

"""
    pretty(T::Type) -> String

Human-readable label for a class type. Defaults to `string(nameof(T))`, with
special cases for names that do not render cleanly (e.g. `IL12_23i` →
`"IL-12/23"`).

# Examples
```jldoctest
julia> pretty(IL12_23i)
"IL-12/23"

julia> pretty(TNFi)
"TNFi"
```
"""
pretty(::Type{T}) where {T} = get(_PRETTY, T, string(nameof(T)))

"""
    moa_symbol(x) -> Symbol

The [`mode_of_action`](@ref) node of `x` as a `Symbol` (via [`label`](@ref)).

# Examples
```jldoctest
julia> moa_symbol(classify("L04AB04"))
:TNFi
```
"""
moa_symbol(x) = label(mode_of_action(category(x)))

"""
    class_symbol(x) -> Symbol

The [`drug_class`](@ref) node of `x` as a `Symbol` (via [`label`](@ref)).

# Examples
```jldoctest
julia> class_symbol(classify("L04AF01"))   # tofacitinib (JAKi) → tsDMARD
:tsDMARD
```
"""
class_symbol(x) = label(drug_class(category(x)))

"""
    count_modes_of_action(xs) -> Int

Number of distinct b/tsDMARD modes of action among the drugs `xs`. csDMARDs and
cortisone are ignored — only [`is_btsdmard`](@ref) drugs are counted.

# Examples
```jldoctest
julia> count_modes_of_action([classify("L04AB04"), classify("L04AF01")])  # TNFi + JAKi
2

julia> count_modes_of_action([classify("L04AB04"), classify("L04AB01")])  # both TNFi
1
```
"""
function count_modes_of_action(xs)
    moas = (mode_of_action(category(x)) for x in xs if is_btsdmard(x))
    return length(unique(moas))
end

"""
    is_d2t(xs) -> Bool

`true` if `xs` spans ≥2 distinct b/tsDMARD modes of action — a proxy for
*difficult-to-treat* disease. Thin wrapper over [`count_modes_of_action`](@ref).

# Examples
```jldoctest
julia> is_d2t([classify("L04AB04"), classify("L04AF01")])   # TNFi + JAKi
true

julia> is_d2t([classify("L04AB04"), classify("L04AB01")])   # both TNFi
false
```
"""
is_d2t(xs) = count_modes_of_action(xs) >= 2
