using Documenter
using TrixiEnzyme

DocMeta.setdocmeta!(TrixiEnzyme, :DocTestSetup, :(using TrixiEnzyme); recursive=true)


push!(LOAD_PATH,"../src/")
makedocs(sitename="TrixiEnzyme.jl",
         doctest = false,
         pages = [
            "Home" => "index.md",
            "API reference" => "api.md",
            "Examples" => "examples.md",
            "GSoC" => "GSoC.md",
            "Notes" => "notes.md",
            "Contact Developer" => "Contact.md",
         ],
         format = Documenter.HTML(prettyurls = false)
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/junyixu/TrixiEnzyme.jl.git",
    devbranch = "main"
)
