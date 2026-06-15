using AntiRheumaticDrugs
using DrugInterface
using Documenter, DocumenterVitepress

# The registry provides concrete drugs, so doctests need nothing beyond `using`.
DocMeta.setdocmeta!(
    AntiRheumaticDrugs,
    :DocTestSetup,
    :(using AntiRheumaticDrugs);
    recursive = true,
)

makedocs(;
    modules  = [AntiRheumaticDrugs, DrugInterface],
    authors  = "Simon Steiger",
    repo     = "https://github.com/simonsteiger/02_outcomes",
    sitename = "AntiRheumaticDrugs.jl",
    format = DocumenterVitepress.MarkdownVitepress(
        repo            = "https://github.com/simonsteiger/02_outcomes",
        devbranch       = "main",
        devurl          = "dev",
        build_vitepress = true,
    ),
    pages = [
        "Home" => "index.md",
        "Guides" => [
            "Taxonomy"   => "guides/taxonomy.md",
            "Registry"   => "guides/registry.md",
            "Predicates" => "guides/predicates.md",
            "Summaries"  => "guides/summaries.md",
        ],
        "API reference" => "api.md",
    ],
    warnonly = false,
    checkdocs = :exports,
    checkdocs_ignored_modules = [DrugInterface],
)

DocumenterVitepress.deploydocs(;
    repo         = "github.com/simonsteiger/02_outcomes.git",
    devbranch    = "main",
    dirname      = "AntiRheumaticDrugs",   # subfolder: TreatmentTrajectories owns the gh-pages root
    push_preview = true,
)
