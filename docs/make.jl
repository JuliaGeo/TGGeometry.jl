using TGGeometry
using Documenter

DocMeta.setdocmeta!(TGGeometry, :DocTestSetup, :(using TGGeometry); recursive=true)

makedocs(;
    modules=[TGGeometry],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    sitename="TGGeometry.jl",
    format=Documenter.HTML(;
        canonical="https://JuliaGeo.github.io/TGGeometry.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    warnonly = true,
)

deploydocs(;
    repo="github.com/JuliaGeo/TGGeometry.jl",
    devbranch="main",
)
