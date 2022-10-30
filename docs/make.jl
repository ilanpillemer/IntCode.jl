using Documenter
using IntCode

makedocs(
    sitename = "IntCode",
    format = Documenter.HTML(),
    modules = [IntCode]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
