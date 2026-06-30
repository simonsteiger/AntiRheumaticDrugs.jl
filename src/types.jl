# ---- drug class taxonomy ----
"""
    DrugClass

Root of the antirheumatic drug-class taxonomy. Every concrete
[`AntiRheumaticDrug`](@ref) carries a class type parameter `C <: DrugClass`,
recoverable with [`category`](@ref). The tree exposes two projection levels: a
coarse *class* node via [`drug_class`](@ref) (one of [`Cortisone`](@ref),
[`csDMARD`](@ref), [`bDMARD`](@ref), [`tsDMARD`](@ref)) and a finer
*mode-of-action* node via [`mode_of_action`](@ref).
"""
abstract type DrugClass end

"Corticosteroid (glucocorticoid). A [`DrugClass`](@ref); not a DMARD."
abstract type Cortisone <: DrugClass end

"Conventional synthetic DMARD (disease-modifying antirheumatic drug)."
abstract type csDMARD <: DrugClass end

"""
    btsDMARD

Umbrella for biologic *and* targeted synthetic DMARDs — the common supertype of
[`bDMARD`](@ref) and [`tsDMARD`](@ref). Membership here is what
[`is_btsdmard`](@ref) and [`count_modes_of_action`](@ref) key on.
"""
abstract type btsDMARD <: DrugClass end

"Targeted synthetic DMARD (e.g. [`JAKi`](@ref), [`PDE4i`](@ref)). A [`btsDMARD`](@ref)."
abstract type tsDMARD <: btsDMARD end

"Biologic DMARD (e.g. [`TNFi`](@ref), [`ILi`](@ref)). A [`btsDMARD`](@ref)."
abstract type bDMARD <: btsDMARD end

"Janus kinase inhibitor (\"JAK inhibitor\"). A targeted synthetic DMARD ([`tsDMARD`](@ref))."
abstract type JAKi <: tsDMARD end

"Phosphodiesterase-4 inhibitor. A targeted synthetic DMARD ([`tsDMARD`](@ref))."
abstract type PDE4i <: tsDMARD end

"Tumour necrosis factor inhibitor. A biologic DMARD ([`bDMARD`](@ref))."
abstract type TNFi <: bDMARD end

"Anti-CD20 B-cell-depleting antibody. A biologic DMARD ([`bDMARD`](@ref))."
abstract type CD20i <: bDMARD end

"Type-I interferon (IFNAR) inhibitor. A biologic DMARD ([`bDMARD`](@ref))."
abstract type IFNi <: bDMARD end

"CD80/86–CD28 co-stimulation inhibitor (abatacept). A biologic DMARD ([`bDMARD`](@ref))."
abstract type CD28i <: bDMARD end

"B-cell activating factor (BAFF/BLyS) inhibitor (belimumab). A biologic DMARD ([`bDMARD`](@ref))."
abstract type BAFFi <: bDMARD end

"""
    ILi

Interleukin-inhibitor umbrella — the supertype of the `IL*i` types
([`IL1i`](@ref), [`IL5i`](@ref), [`IL6i`](@ref), [`IL17i`](@ref),
[`IL23i`](@ref), [`IL12_23i`](@ref)). A biologic DMARD ([`bDMARD`](@ref)).
"""
abstract type ILi <: bDMARD end

"Interleukin-1 inhibitor. An [`ILi`](@ref) biologic DMARD."
abstract type IL1i <: ILi end

"Interleukin-5 inhibitor. An [`ILi`](@ref) biologic DMARD."
abstract type IL5i <: ILi end

"Interleukin-6 inhibitor. An [`ILi`](@ref) biologic DMARD."
abstract type IL6i <: ILi end

"Interleukin-17 inhibitor. An [`ILi`](@ref) biologic DMARD."
abstract type IL17i <: ILi end

"Interleukin-23 inhibitor. An [`ILi`](@ref) biologic DMARD."
abstract type IL23i <: ILi end

"Interleukin-12/23 (shared p40) inhibitor (ustekinumab). An [`ILi`](@ref) biologic DMARD."
abstract type IL12_23i <: ILi end

# ---- route taxonomy ----
"""
    AbstractRoute

Root of the administration-route taxonomy. A drug's route is read with
[`route_of`](@ref); [`is_systemic`](@ref) tests for [`Systemic`](@ref). Concrete
routes are zero-field singletons (`Systemic()`, `Topical()`, …).
"""
abstract type AbstractRoute end

"Whole-body administration (oral, IV, SC, IM). An [`AbstractRoute`](@ref)."
struct Systemic <: AbstractRoute end

"""
    Local

Umbrella for non-systemic routes: [`Topical`](@ref), [`Ophthalmic`](@ref),
[`Nasal`](@ref), [`Inhaled`](@ref), [`Intestinal`](@ref), [`Rectal`](@ref).
"""
abstract type Local <: AbstractRoute end

"Skin application. A [`Local`](@ref) route."
struct Topical <: Local end

"Eye application. A [`Local`](@ref) route."
struct Ophthalmic <: Local end

"Nasal application. A [`Local`](@ref) route."
struct Nasal <: Local end

"Inhalation (airways/lungs). A [`Local`](@ref) route."
struct Inhaled <: Local end

"Enteric, gut-local action. A [`Local`](@ref) route."
struct Intestinal <: Local end

"Rectal application. A [`Local`](@ref) route."
struct Rectal <: Local end

# ---- drug struct ----
"""
    AntiRheumaticDrug{C<:DrugClass}

A registered antirheumatic substance, tagged at the type level with its drug
class `C`. Fields: `name`, `atc` (WHO ATC code), `brands::Vector{String}`, and
`route::`[`AbstractRoute`](@ref). Recover the class with [`category`](@ref), the
substance name with [`substance`](@ref), and the route with [`route_of`](@ref).
Look one up by ATC code with [`classify`](@ref). Implements the DrugInterface
`AbstractAntiRheumaticDrug` contract.
"""
struct AntiRheumaticDrug{C <: DrugClass} <: DrugInterface.AbstractAntiRheumaticDrug
    name::String
    atc::String
    brands::Vector{String}
    route::AbstractRoute
end

"""
    category(d::AntiRheumaticDrug) -> Type{<:DrugClass}

The class type parameter `C` of `d` — the *finest* node in the
[`DrugClass`](@ref) tree (e.g. `TNFi`). Project it onto coarser nodes with
[`drug_class`](@ref) or [`mode_of_action`](@ref).

# Examples
```jldoctest
julia> class_symbol(classify("L04AB04"))   # category is TNFi; class node is bDMARD
:bDMARD
```
"""
category(::AntiRheumaticDrug{C}) where {C} = C

"""
    AnonymousDrug{C<:DrugClass}

A class-known, identity-unknown antirheumatic drug: carries its
[`DrugClass`](@ref) `C` at the type level but holds no substance-level fields.
Use it as a fallback when a record's drug class is known but its ATC code does
not resolve (see [`classify`](@ref)). Class predicates work on it;
[`substance`](@ref) and [`route_of`](@ref) return `missing`. Implements the
DrugInterface `AbstractAntiRheumaticDrug` contract.
"""
struct AnonymousDrug{C <: DrugClass} <: DrugInterface.AbstractAntiRheumaticDrug end

category(::AnonymousDrug{C}) where {C} = C
