using Test
using AntiRheumaticDrugs
using DrugInterface

@testset "AntiRheumaticDrugs" begin
    @test true  # scaffold smoke test, replaced as tasks land

    using AntiRheumaticDrugs:
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
        IL12_23i

    @testset "drug class hierarchy" begin
        @test JAKi <: tsDMARD <: btsDMARD <: DrugClass
        @test PDE4i <: tsDMARD
        @test TNFi <: bDMARD <: btsDMARD
        @test IL6i <: ILi <: bDMARD
        @test CD28i <: bDMARD && BAFFi <: bDMARD && IFNi <: bDMARD && CD20i <: bDMARD
        @test Cortisone <: DrugClass && csDMARD <: DrugClass
        @test !(Cortisone <: btsDMARD) && !(csDMARD <: btsDMARD)
    end

    using AntiRheumaticDrugs:
        AbstractRoute,
        Systemic,
        Local,
        Topical,
        Ophthalmic,
        Nasal,
        Inhaled,
        Intestinal,
        Rectal

    @testset "route hierarchy" begin
        @test Systemic <: AbstractRoute
        @test Local <: AbstractRoute
        for R in (Topical, Ophthalmic, Nasal, Inhaled, Intestinal, Rectal)
            @test R <: Local
        end
        @test Systemic() isa Systemic
        @test Topical() isa Local
        @test !(Systemic() isa Local)
    end

    using AntiRheumaticDrugs: AntiRheumaticDrug, category

    @testset "AntiRheumaticDrug struct" begin
        d = AntiRheumaticDrug{TNFi}("Adalimumab", "L04AB04", ["Humira"], Systemic())
        @test d.name == "Adalimumab"
        @test d.atc == "L04AB04"
        @test d.brands == ["Humira"]
        @test d.route isa Systemic
        @test category(d) === TNFi
    end

    using AntiRheumaticDrugs: REGISTRY, classify, try_classify, is_registered

    @testset "registry + lookup" begin
        @test is_registered("L04AB04")
        @test !is_registered("ZZZZZZ")
        @test try_classify("ZZZZZZ") === nothing
        @test try_classify("L04AB04") !== nothing &&
            try_classify("L04AB04").name == "Adalimumab"
        @test classify("L04AB04").name == "Adalimumab"
        @test category(classify("L04AB04")) === TNFi
        @test category(classify("H02AB06")) === Cortisone
        @test classify("S01BA04").route isa Ophthalmic   # prednisolone eye drops
        @test classify("H02AB06").route isa Systemic      # prednisolone systemic
        @test category(classify("L04AA32")) === PDE4i      # apremilast
        @test category(classify("L04AA24")) === CD28i      # abatacept
        @test category(classify("L04AG04")) === BAFFi      # belimumab
        @test category(classify("L01XC10")) === CD20i     # ofatumumab (Arzerra)
        @test category(classify("M01CB01")) === csDMARD   # sodium aurothiomalate (gold)
        @test category(classify("M01CB03")) === csDMARD   # auranofin (Ridaura)
        @test category(classify("M01CC01")) === csDMARD   # penicillamine
        @test_throws KeyError classify("ZZZZZZ")
        # integrity: every key is a well-formed 5th-level ATC code.
        # Guards against any typo that produces a malformed code (safeguard 1).
        let atc_pat = r"^[A-Z]\d{2}[A-Z]{2}\d{2}$"
            @test all(k -> occursin(atc_pat, k), keys(REGISTRY))
        end
    end

    using AntiRheumaticDrugs:
        route_of,
        drug_of,
        is_class,
        is_cortisone,
        is_csdmard,
        is_bdmard,
        is_tsdmard,
        is_btsdmard,
        is_dmard

    @testset "class predicates" begin
        ada = classify("L04AB04")   # TNFi
        mtx = classify("L04AX03")   # csDMARD
        pred = classify("H02AB06")  # Cortisone
        bari = classify("L04AF02")  # JAKi (tsDMARD)
        @test is_bdmard(ada) && is_btsdmard(ada) && is_dmard(ada)
        @test !is_csdmard(ada) && !is_cortisone(ada)
        @test is_csdmard(mtx) && is_dmard(mtx) && !is_btsdmard(mtx)
        @test is_cortisone(pred) && !is_dmard(pred)
        @test is_tsdmard(bari) && is_btsdmard(bari) && !is_bdmard(bari)
        @test is_class(ada, TNFi) && !is_class(mtx, bDMARD)
        @test drug_of(ada) === ada && route_of(ada) isa Systemic
    end

    using AntiRheumaticDrugs: is_systemic, is_substance

    @testset "route + substance predicates" begin
        @test is_systemic(classify("H02AB06"))      # systemic prednisolone
        @test !is_systemic(classify("S01BA04"))     # ophthalmic prednisolone
        @test !is_systemic(classify("A07EA06"))     # intestinal budesonide
        @test !is_systemic(classify("D11AH01"))     # topical tacrolimus
        @test !is_systemic(classify("R01AD05"))     # nasal budesonide
        @test !is_systemic(classify("R03AK07"))     # inhaled budesonide
        @test !is_systemic(classify("C05AA04"))     # rectal prednisolone
        @test is_substance(classify("L04AX03"), "Methotrexate")
        @test !is_substance(classify("L04AB04"), "Methotrexate")
    end

    using AntiRheumaticDrugs: mode_of_action, drug_class

    @testset "level projections" begin
        @test mode_of_action(classify("L04AC07")) === IL6i      # tocilizumab
        @test mode_of_action(classify("L04AF02")) === JAKi      # baricitinib
        @test mode_of_action(classify("L04AA32")) === PDE4i     # apremilast
        @test mode_of_action(classify("L04AA24")) === CD28i     # abatacept
        @test drug_class(classify("L04AC07")) === bDMARD
        @test drug_class(classify("L04AF02")) === tsDMARD
        @test drug_class(classify("L04AX03")) === csDMARD       # methotrexate
        @test drug_class(classify("H02AB06")) === Cortisone
        # bare-type contract (spec lists Type{C} methods directly)
        @test mode_of_action(IL6i) === IL6i
        @test drug_class(IL6i) === bDMARD
        # mode_of_action is undefined for csDMARD / Cortisone
        @test_throws MethodError mode_of_action(classify("L04AX03"))
        @test_throws MethodError mode_of_action(classify("H02AB06"))
    end

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

    using AntiRheumaticDrugs: label, pretty, moa_symbol, class_symbol

    @testset "materialization" begin
        @test label(IL6i) === :IL6i
        @test moa_symbol(classify("L04AC07")) === :IL6i
        @test moa_symbol(classify("L04AC05")) === :IL12_23i   # ustekinumab
        @test class_symbol(classify("L04AC07")) === :bDMARD
        @test class_symbol(classify("L04AF02")) === :tsDMARD
        @test class_symbol(classify("L04AX03")) === :csDMARD
        @test pretty(IL12_23i) == "IL-12/23"
        @test pretty(TNFi) == "TNFi"
    end

    using AntiRheumaticDrugs: count_modes_of_action, is_d2t

    @testset "mode-of-action counting" begin
        tnf = classify("L04AB04")  # TNFi
        il6 = classify("L04AC07")  # IL6i
        jak = classify("L04AF02")  # JAKi
        tnf2 = classify("L04AB01")  # TNFi (different drug, same MoA)
        mtx = classify("L04AX03")  # csDMARD — ignored
        @test count_modes_of_action([tnf, il6, jak]) == 3
        @test count_modes_of_action([tnf, tnf2]) == 1          # same MoA
        @test count_modes_of_action([tnf, mtx]) == 1           # csDMARD ignored
        @test count_modes_of_action([mtx]) == 0
        @test count_modes_of_action(AntiRheumaticDrug[]) == 0               # empty
        @test !is_d2t(AntiRheumaticDrug[])                                   # empty
        @test is_d2t([tnf, il6])                                # 2 distinct MoA
        @test !is_d2t([tnf, tnf2])                              # 1 distinct MoA
        @test !is_d2t([tnf])
    end

    @testset "registry coverage and corrections" begin
        # corrections from the validation log
        @test classify("L04AF03").brands == ["Rinvoq"]        # not "Rimvoq"
        @test classify("H02AB04").name == "Methylprednisolone"
        @test !is_registered("V04CL")                          # removed (not a steroid)
        # legacy ATC codes still present in SRQ data (2012-2024) map to the
        # same substance as their current codes (found via golden-master audit)
        @test category(classify("L04AA13")) === csDMARD &&
            classify("L04AA13").name == "Leflunomide"
        @test category(classify("L04AA26")) === BAFFi &&
            classify("L04AA26").name == "Belimumab"
        # every expected substance present at least once
        expected = [
            "Betamethasone",
            "Methylprednisolone",
            "Prednisolone",
            "Hydrocortisone",
            "Dexamethasone",
            "Budesonide",
            "Azathioprine",
            "Ciclosporin",
            "Hydroxychloroquine",
            "Chloroquine",
            "Leflunomide",
            "Methotrexate",
            "Mycophenolic acid",
            "Sirolimus",
            "Sulfasalazine",
            "Tacrolimus",
            "Voclosporin",
            "Filgotinib",
            "Baricitinib",
            "Upadacitinib",
            "Tofacitinib",
            "Apremilast",
            "Obinutuzumab",
            "Rituximab",
            "Adalimumab",
            "Etanercept",
            "Certolizumab pegol",
            "Infliximab",
            "Golimumab",
            "Anifrolumab",
            "Anakinra",
            "Canakinumab",
            "Benralizumab",
            "Mepolizumab",
            "Tocilizumab",
            "Sarilumab",
            "Ixekizumab",
            "Secukinumab",
            "Bimekizumab",
            "Guselkumab",
            "Risankizumab",
            "Ustekinumab",
            "Abatacept",
            "Belimumab",
            "Ofatumumab",
            "Sodium aurothiomalate",
            "Auranofin",
            "Penicillamine",
        ]
        present = Set(d.name for d in values(REGISTRY))
        @test all(in(present), expected)
        # every registry value's category is a leaf admitted by the tree
        @test all(d -> category(d) <: DrugClass, values(REGISTRY))
    end

    # (legacy code, current code) pairs verified against the WHO cumulative ATC
    # alterations table (atcddd.fhi.no), confirmed by independent dual-derivation
    # — see .claude/notes/reports/2026-06-11-pre2021-atc-audit.md
    # NB: plain assignment, not `const` — this binding is local to the outer
    # @testset block, and Julia rejects `const` on local variables.
    LEGACY_ATC_ALIASES = [
        # already present in registry
        ("L04AA13", "L04AK01"),   # Leflunomide    (WHO 2024)
        ("L04AA26", "L04AG04"),   # Belimumab      (WHO 2024)
        ("L01BA01", "L04AX03"),   # Methotrexate   (WHO 2017)
        # 2024 L04A immunosuppressant revision
        ("L04AA10", "L04AH01"),   # Sirolimus      (WHO 2024)
        ("L04AA29", "L04AF01"),   # Tofacitinib    (WHO 2024)
        ("L04AA37", "L04AF02"),   # Baricitinib    (WHO 2024)
        ("L04AA44", "L04AF03"),   # Upadacitinib   (WHO 2024)
        ("L04AA45", "L04AF04"),   # Filgotinib     (WHO 2024)
        ("L04AA51", "L04AG11"),   # Anifrolumab    (WHO 2024)
        # 2022 antineoplastic monoclonal-antibody renumbering
        ("L01XC02", "L01FA01"),   # Rituximab      (WHO 2022)
        ("L01XC15", "L01FA03"),   # Obinutuzumab   (WHO 2022)
        # 2017
        ("L04AC06", "R03DX09"),   # Mepolizumab    (WHO 2017)
        # 2008 L04AA -> L04AB/AC/AD split
        ("L04AA01", "L04AD01"),   # Ciclosporin    (WHO 2008)
        ("L04AA05", "L04AD02"),   # Tacrolimus     (WHO 2008)
        ("L04AA11", "L04AB01"),   # Etanercept     (WHO 2008)
        ("L04AA12", "L04AB02"),   # Infliximab     (WHO 2008)
        ("L04AA14", "L04AC03"),   # Anakinra       (WHO 2008)
        ("L04AA17", "L04AB04"),   # Adalimumab     (WHO 2008)
    ]

    @testset "legacy alias name-consistency" begin
        # Safeguard 2: every legacy alias must map to a substance that also
        # exists under a NON-alias (current) code. A typo'd alias code that
        # lands on the wrong drug, or aliases a drug we don't track, fails here.
        alias_codes = Set(first(p) for p in LEGACY_ATC_ALIASES)
        names_under_current = Set(d.name for (k, d) in REGISTRY if !(k in alias_codes))
        for old in alias_codes
            @test is_registered(old)
            @test classify(old).name in names_under_current
        end
    end

    @testset "legacy alias round-trip" begin
        # Safeguard 6: each legacy code resolves to the SAME substance as its
        # current code — char-for-char agreement with the WHO alteration record.
        for (old, current) in LEGACY_ATC_ALIASES
            @test is_registered(old)
            @test is_registered(current)
            @test classify(old).name == classify(current).name
        end
    end

    @testset "DrugInterface conformance" begin
        ada = classify("L04AB04")          # adalimumab, a TNFi (bDMARD)
        mtx = classify("L01BA01")          # methotrexate, a csDMARD
        @test ada isa DrugInterface.AbstractAntiRheumaticDrug
        @test substance(mtx) == "Methotrexate"
        @test is_btsdmard(ada)             # via the DrugInterface fallback
        @test !is_btsdmard(mtx)
        @test is_dmard(mtx)
        @test is_substance(mtx, "Methotrexate")
    end

    @testset "AnonymousDrug type" begin
        a = AnonymousDrug{csDMARD}()
        @test a isa DrugInterface.AbstractAntiRheumaticDrug
        @test category(a) === csDMARD
        @test category(AnonymousDrug{TNFi}()) === TNFi
    end
end
