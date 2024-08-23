using Documenter
using TrixiEnzyme

push!(LOAD_PATH,"../src/")
makedocs(sitename="TrixiEnzyme.jl",
         doctest = false,
         pages = [
            "Index" => "index.md",
            "An other page" => "anotherPage.md",
            "Acknowledgments" => "Acknowledgments.md",
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
