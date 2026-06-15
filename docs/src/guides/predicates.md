# Class predicates

[`is_class`](@ref) is the generic test: it asks whether a drug's
[`category`](@ref) is a subtype of a given [`DrugClass`](@ref) node.

```@example pred
using AntiRheumaticDrugs

ada = classify("L04AB04")   # TNFi <: bDMARD <: btsDMARD
(is_class(ada, bDMARD), is_class(ada, btsDMARD), is_class(ada, tsDMARD))
```

The named predicates re-exported from `DrugInterface` are the common
specialisations — [`is_cortisone`](@ref), [`is_csdmard`](@ref),
[`is_bdmard`](@ref), [`is_tsdmard`](@ref), and the umbrella
[`is_btsdmard`](@ref):

```@example pred
tof = classify("L04AF01")   # JAKi <: tsDMARD
(is_tsdmard(tof), is_bdmard(tof), is_btsdmard(tof), is_csdmard(tof))
```

Route is orthogonal to class — [`is_systemic`](@ref) tests the
[`route_of`](@ref):

```@example pred
(is_systemic(classify("L04AB04")), is_systemic(classify("D07AC01")))
```
