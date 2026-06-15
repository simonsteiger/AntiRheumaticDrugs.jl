# Summarising a treatment mix

Given a collection of drugs, [`count_modes_of_action`](@ref) counts the *distinct*
b/tsDMARD modes of action. csDMARDs and cortisone are ignored, so adding
methotrexate to a biologic does not change the count.

```@example sum
using AntiRheumaticDrugs

mix = classify.(["L04AB04", "L04AF01", "L04AX03"])   # TNFi, JAKi, methotrexate
count_modes_of_action(mix)
```

[`is_d2t`](@ref) flags *difficult-to-treat* disease — ≥2 distinct modes of
action:

```@example sum
two_tnfi = classify.(["L04AB04", "L04AB01"])         # both TNFi → one MOA

(is_d2t(mix), is_d2t(two_tnfi))
```

The per-drug labels feeding these summaries come from [`moa_symbol`](@ref) and
[`class_symbol`](@ref). A mode of action is only defined for b/tsDMARDs, so
[`moa_symbol`](@ref) is queried for those drugs only — csDMARDs such as
methotrexate carry no MOA node:

```@example sum
[(substance(d), class_symbol(d), moa_symbol(d)) for d in mix if is_btsdmard(d)]
```
