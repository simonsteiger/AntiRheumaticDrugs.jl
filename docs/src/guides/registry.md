# The registry: looking drugs up

The package keys drugs by WHO **ATC code**. [`classify`](@ref) returns the
registered [`AntiRheumaticDrug`](@ref); it throws on an unknown code.

```@example reg
using AntiRheumaticDrugs

ada = classify("L04AB04")
(substance(ada), class_symbol(ada))
```

For codes that may be absent, use [`is_registered`](@ref) to test or
[`try_classify`](@ref) to get `nothing` instead of an exception:

```@example reg
(is_registered("L04AB04"), is_registered("NOT_A_CODE"), try_classify("NOT_A_CODE"))
```

## Legacy ATC codes

WHO periodically re-codes substances. The registry holds the **current** code and
aliases the superseded ones, so extracts spanning several years still resolve. For
example, tofacitinib's pre-2024 code `L04AA29` maps to the same drug as the
current `L04AF01`:

```@example reg
(substance(classify("L04AA29")), substance(classify("L04AF01")))
```
