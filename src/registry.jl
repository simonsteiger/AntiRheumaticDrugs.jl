const _ROWS = Tuple{DataType,String,String,AbstractRoute,Vector{String}}[
    # ---- Cortisone ----
    (Cortisone, "Betamethasone", "D05AX52", Topical(),    String[]),
    (Cortisone, "Betamethasone", "D07AC01", Topical(),    String[]),
    (Cortisone, "Betamethasone", "D07CC01", Topical(),    String[]),
    (Cortisone, "Betamethasone", "D07XC01", Topical(),    String[]),
    (Cortisone, "Betamethasone", "H02AB01", Systemic(),   String[]),
    (Cortisone, "Methylprednisolone", "H02AB04", Systemic(), String[]),
    (Cortisone, "Prednisolone", "A07EA01", Intestinal(), String[]),
    (Cortisone, "Prednisolone", "C05AA04", Rectal(),     String[]),
    (Cortisone, "Prednisolone", "H02AB06", Systemic(),   String[]),
    (Cortisone, "Prednisolone", "S01BA04", Ophthalmic(), String[]),
    (Cortisone, "Hydrocortisone", "C05AA01", Rectal(),     String[]),
    (Cortisone, "Hydrocortisone", "D01AC20", Topical(),    String[]),
    (Cortisone, "Hydrocortisone", "D06BB53", Topical(),    String[]),
    (Cortisone, "Hydrocortisone", "D07AA02", Topical(),    String[]),
    (Cortisone, "Hydrocortisone", "D07AB02", Topical(),    String[]),
    (Cortisone, "Hydrocortisone", "D07CA01", Topical(),    String[]),
    (Cortisone, "Hydrocortisone", "D07XA01", Topical(),    String[]),
    (Cortisone, "Hydrocortisone", "H02AB09", Systemic(),   String[]),
    (Cortisone, "Hydrocortisone", "S01BA02", Ophthalmic(), String[]),
    (Cortisone, "Hydrocortisone", "S03CA04", Ophthalmic(), String[]),
    (Cortisone, "Dexamethasone", "H02AB02", Systemic(),   String[]),
    (Cortisone, "Dexamethasone", "S01BA01", Ophthalmic(), String[]),
    (Cortisone, "Dexamethasone", "S01CA01", Ophthalmic(), String[]),
    (Cortisone, "Budesonide", "A07EA06", Intestinal(), String[]),
    (Cortisone, "Budesonide", "R01AD05", Nasal(),      String[]),
    (Cortisone, "Budesonide", "R03AK07", Inhaled(),    String[]),
    (Cortisone, "Budesonide", "R03AL11", Inhaled(),    String[]),
    (Cortisone, "Budesonide", "R03BA02", Inhaled(),    String[]),
    # ---- csDMARD ----
    (csDMARD, "Azathioprine", "L04AX01", Systemic(), String[]),
    (csDMARD, "Ciclosporin", "L04AD01", Systemic(),   String[]),
    (csDMARD, "Ciclosporin", "S01XA18", Ophthalmic(), String[]),
    (csDMARD, "Hydroxychloroquine", "P01BA02", Systemic(), String[]),
    (csDMARD, "Chloroquine", "P01BA01", Systemic(), String[]),
    (csDMARD, "Leflunomide", "L04AK01", Systemic(), String[]),
    (csDMARD, "Leflunomide", "L04AA13", Systemic(), String[]),   # legacy ATC code (-> L04AK01, WHO 2024)
    (csDMARD, "Methotrexate", "L01BA01", Systemic(), String[]),
    (csDMARD, "Methotrexate", "L04AX03", Systemic(), String[]),
    (csDMARD, "Mycophenolic acid", "L04AA06", Systemic(), String[]),
    (csDMARD, "Sirolimus", "L04AH01", Systemic(), String[]),
    (csDMARD, "Sulfasalazine", "A07EC01", Systemic(), String[]),
    (csDMARD, "Tacrolimus", "D11AH01", Topical(),  String[]),
    (csDMARD, "Tacrolimus", "L04AD02", Systemic(), String[]),
    (csDMARD, "Voclosporin", "L04AD03", Systemic(), String[]),
    # ---- tsDMARD ----
    (JAKi,  "Filgotinib",   "L04AF04", Systemic(), ["Jyseleca"]),
    (JAKi,  "Baricitinib",  "L04AF02", Systemic(), ["Olumiant"]),
    (JAKi,  "Upadacitinib", "L04AF03", Systemic(), ["Rinvoq"]),
    (JAKi,  "Tofacitinib",  "L04AF01", Systemic(), ["Xeljanz"]),
    (PDE4i, "Apremilast",   "L04AA32", Systemic(), ["Otezla"]),
    # ---- bDMARD ----
    (CD20i, "Obinutuzumab", "L01FA03", Systemic(), ["Gazyvaro"]),
    (CD20i, "Rituximab", "L01FA01", Systemic(), ["MabThera","Ritemvia","Rixathon","Ruxience","Truxima"]),
    (TNFi, "Adalimumab", "L04AB04", Systemic(), ["Amgevita","Hukyndra","Hulio","Humira","Hyrimoz","Idacio","Imraldi","Yuflyma"]),
    (TNFi, "Etanercept", "L04AB01", Systemic(), ["Benepali","Enbrel","Erelzi"]),
    (TNFi, "Certolizumab pegol", "L04AB05", Systemic(), ["Cimzia"]),
    (TNFi, "Infliximab", "L04AB02", Systemic(), ["Flixabi","Inflectra","Remicade","Remsima","Zessly"]),
    (TNFi, "Golimumab", "L04AB06", Systemic(), ["Simponi","Gobivaz"]),
    (IFNi, "Anifrolumab", "L04AG11", Systemic(), ["Saphnelo"]),
    (IL1i, "Anakinra", "L04AC03", Systemic(), ["Kineret"]),
    (IL1i, "Canakinumab", "L04AC08", Systemic(), ["Ilaris"]),
    (IL5i, "Benralizumab", "R03DX10", Systemic(), ["Fasenra"]),
    (IL5i, "Mepolizumab", "R03DX09", Systemic(), ["Nucala"]),
    (IL6i, "Tocilizumab", "L04AC07", Systemic(), ["RoActemra","Tyenne"]),
    (IL6i, "Sarilumab", "L04AC14", Systemic(), ["Kevzara"]),
    (IL17i, "Ixekizumab", "L04AC13", Systemic(), ["Taltz"]),
    (IL17i, "Secukinumab", "L04AC10", Systemic(), ["Cosentyx"]),
    (IL17i, "Bimekizumab", "L04AC21", Systemic(), ["Bimzelx"]),
    (IL23i, "Guselkumab", "L04AC16", Systemic(), ["Tremfya"]),
    (IL23i, "Risankizumab", "L04AC18", Systemic(), ["Skyrizi"]),
    (IL12_23i, "Ustekinumab", "L04AC05", Systemic(), ["Stelara","Pyzchiva","Uzpruvo","Wezenla","Steqeyma"]),
    (CD28i, "Abatacept", "L04AA24", Systemic(), ["Orencia"]),
    (BAFFi, "Belimumab", "L04AG04", Systemic(), ["Benlysta"]),
    (BAFFi, "Belimumab", "L04AA26", Systemic(), ["Benlysta"]),   # legacy ATC code (-> L04AG04, WHO 2024)
    # ---- legacy ATC codes (WHO alteration audit, 2026-06-11) ----
    # Drugs the registry already holds under current codes, aliased to the
    # pre-revision codes that SRQ extracts (2012-2024) may still carry. Verified
    # against the WHO cumulative alterations table by independent dual-derivation.
    # See .claude/notes/reports/2026-06-11-pre2021-atc-audit.md
    (csDMARD, "Ciclosporin", "L04AA01", Systemic(), String[]),                                                                      # -> L04AD01, WHO 2008
    (csDMARD, "Tacrolimus", "L04AA05", Systemic(), String[]),                                                                       # -> L04AD02, WHO 2008
    (csDMARD, "Sirolimus", "L04AA10", Systemic(), String[]),                                                                        # -> L04AH01, WHO 2024
    (JAKi,  "Tofacitinib",  "L04AA29", Systemic(), ["Xeljanz"]),                                                                    # -> L04AF01, WHO 2024
    (JAKi,  "Baricitinib",  "L04AA37", Systemic(), ["Olumiant"]),                                                                   # -> L04AF02, WHO 2024
    (JAKi,  "Upadacitinib", "L04AA44", Systemic(), ["Rinvoq"]),                                                                     # -> L04AF03, WHO 2024
    (JAKi,  "Filgotinib",   "L04AA45", Systemic(), ["Jyseleca"]),                                                                   # -> L04AF04, WHO 2024
    (IFNi, "Anifrolumab", "L04AA51", Systemic(), ["Saphnelo"]),                                                                     # -> L04AG11, WHO 2024
    (TNFi, "Etanercept", "L04AA11", Systemic(), ["Benepali","Enbrel","Erelzi"]),                                                    # -> L04AB01, WHO 2008
    (TNFi, "Infliximab", "L04AA12", Systemic(), ["Flixabi","Inflectra","Remicade","Remsima","Zessly"]),                            # -> L04AB02, WHO 2008
    (TNFi, "Adalimumab", "L04AA17", Systemic(), ["Amgevita","Hukyndra","Hulio","Humira","Hyrimoz","Idacio","Imraldi","Yuflyma"]),  # -> L04AB04, WHO 2008
    (IL1i, "Anakinra", "L04AA14", Systemic(), ["Kineret"]),                                                                         # -> L04AC03, WHO 2008
    (IL5i, "Mepolizumab", "L04AC06", Systemic(), ["Nucala"]),                                                                       # -> R03DX09, WHO 2017
    (CD20i, "Rituximab", "L01XC02", Systemic(), ["MabThera","Ritemvia","Rixathon","Ruxience","Truxima"]),                          # -> L01FA01, WHO 2022
    (CD20i, "Obinutuzumab", "L01XC15", Systemic(), ["Gazyvaro"]),                                                                   # -> L01FA03, WHO 2022
]

const REGISTRY = let d = Dict{String,AntiRheumaticDrug}()
    for (C, name, atc, route, brands) in _ROWS
        haskey(d, atc) && error("duplicate ATC code in registry: $atc")
        # NB: _ROWS column order is (C, name, atc, route, brands);
        # AntiRheumaticDrug's field order is (name, atc, brands, route) — brands/route are swapped here.
        d[atc] = AntiRheumaticDrug{C}(name, atc, brands, route)
    end
    d
end
