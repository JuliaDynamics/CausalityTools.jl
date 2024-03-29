cd(@__DIR__)
# Doc-specific (remaining packages are imported  in `build_docs_with_style.jl`, which is
# downloaded)
using DocumenterCitations
import Downloads

# Packages used in the doc build.
using CausalityTools
using ComplexityMeasures
using StateSpaceSets

pages = [
    "Overview" => "index.md",
    "Association measures" => "measures.md",
    "Independence testing" => "independence.md",
    "Causal graphs" => "causal_graphs.md",
    "APIs and estimators" => "api.md",
    "Examples" => "examples.md",
    "Predefined systems" => "coupled_systems.md",
    "Experimental" => "experimental.md",
    "References" => "references.md",
]

Downloads.download(
    "https://raw.githubusercontent.com/JuliaDynamics/doctheme/master/build_docs_with_style.jl",
    joinpath(@__DIR__, "build_docs_with_style.jl")
)
include("build_docs_with_style.jl")

bibliography = CitationBibliography(
    joinpath(@__DIR__, "refs.bib");
    style=:authoryear
)

build_docs_with_style(pages, CausalityTools, ComplexityMeasures, StateSpaceSets;
    expandfirst = ["index.md"],
    bib = bibliography,
    pages = pages,
    authors = "Kristian Agasøster Haaga, David Diego, Tor Einar Møller, George Datseris",
)
