module AntiRheumaticDrugs

using DrugInterface

include("types.jl")
include("registry.jl")
include("api.jl")

export AntiRheumaticDrug,
    DrugClass,
    Cortisone,
    csDMARD,
    btsDMARD,
    tsDMARD,
    bDMARD,
    JAKi,
    PDE4i,
    TNFi,
    CD20i,
    IFNi,
    CD28i,
    BAFFi,
    ILi,
    IL1i,
    IL5i,
    IL6i,
    IL17i,
    IL23i,
    IL12_23i,
    AbstractRoute,
    Systemic,
    Local,
    Topical,
    Ophthalmic,
    Nasal,
    Inhaled,
    Intestinal,
    Rectal
export classify, try_classify, is_registered, category, route_of, drug_of
export is_class,
    is_cortisone,
    is_csdmard,
    is_bdmard,
    is_tsdmard,
    is_btsdmard,
    is_dmard,
    is_systemic,
    is_substance
export substance, mode_of_action, drug_class, label, pretty, moa_symbol, class_symbol
export count_modes_of_action, is_d2t

end # module
