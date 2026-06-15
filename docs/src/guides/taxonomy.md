# The drug-class & route taxonomy

Each [`AntiRheumaticDrug`](@ref) is tagged with a class type parameter
`C <: `[`DrugClass`](@ref), recovered with [`category`](@ref). The class tree
nests from broad to specific:

- [`Cortisone`](@ref) — corticosteroids (not a DMARD)
- [`csDMARD`](@ref) — conventional synthetic DMARDs
- [`btsDMARD`](@ref) — the biologic-or-targeted-synthetic umbrella, splitting into
  - [`bDMARD`](@ref) — biologics: [`TNFi`](@ref), [`CD20i`](@ref), [`IFNi`](@ref),
    [`CD28i`](@ref), [`BAFFi`](@ref), and the interleukin family [`ILi`](@ref)
    ([`IL1i`](@ref), [`IL5i`](@ref), [`IL6i`](@ref), [`IL17i`](@ref),
    [`IL23i`](@ref), [`IL12_23i`](@ref))
  - [`tsDMARD`](@ref) — targeted synthetics: [`JAKi`](@ref), [`PDE4i`](@ref)

[`category`](@ref) returns the *finest* node. Two projections climb the tree:

```@example tax
using AntiRheumaticDrugs

ada = classify("L04AB04")
(category(ada), drug_class(category(ada)), mode_of_action(category(ada)))
```

Use the `*_symbol` helpers for stable `Symbol`s, or [`pretty`](@ref) for a
display string:

```@example tax
(class_symbol(ada), moa_symbol(ada), pretty(category(ada)))
```

Routes form a parallel tree rooted at [`AbstractRoute`](@ref): [`Systemic`](@ref)
versus the [`Local`](@ref) routes ([`Topical`](@ref), [`Ophthalmic`](@ref),
[`Nasal`](@ref), [`Inhaled`](@ref), [`Intestinal`](@ref), [`Rectal`](@ref)).

```@example tax
(route_of(classify("L04AB04")), route_of(classify("D07AC01")))
```
