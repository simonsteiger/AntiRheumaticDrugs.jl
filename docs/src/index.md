```@raw html
---
layout: home

hero:
  name: "AntiRheumaticDrugs.jl"
  text: "An ATC-registry of antirheumatic drugs"
  tagline: Classify drugs by ATC code and benefit from a rich type hierarchy
  actions:
    - theme: brand
      text: Get started
      link: /guides/taxonomy
    - theme: alt
      text: API reference
      link: /api
    - theme: alt
      text: View on GitHub
      link: https://github.com/simonsteiger/AntiRheumaticDrugs.jl
---
```

## What is AntiRheumaticDrugs?

`AntiRheumaticDrugs` maps WHO **ATC codes** to concrete `AntiRheumaticDrug`
values, each tagged at the type level with its drug class (`TNFi`, `JAKi`,
`csDMARD`, …) and carrying its administration route. Look a drug up with
[`classify`](@ref), read its class with [`category`](@ref) or
[`class_symbol`](@ref), and summarise a set of drugs with
[`count_modes_of_action`](@ref) and [`is_d2t`](@ref). The package implements the
`DrugInterface` contract, so its drugs drop into `TreatmentTrajectories` windows.

## Installation

This package is not yet registered. Add it via URL:

```julia
using Pkg
Pkg.add(url = "https://github.com/simonsteiger/AntiRheumaticDrugs.jl")
```

## Quick example

```@example quick
using AntiRheumaticDrugs

ada = classify("L04AB04")          # adalimumab, by ATC code
(substance(ada), class_symbol(ada), moa_symbol(ada), is_systemic(ada))
```

Summarise a mix of drugs — methotrexate (a csDMARD) is ignored by the
mode-of-action count; the TNFi + JAKi pair makes it *difficult-to-treat*:

```@example quick
mix = classify.(["L04AB04", "L04AF01", "L04AX03"])   # TNFi, JAKi, methotrexate

(count_modes_of_action(mix), is_d2t(mix))
```
