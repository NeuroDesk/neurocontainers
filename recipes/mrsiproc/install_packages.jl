import Pkg
packages = ["MAT", "Comonicon"]
Pkg.add(packages)
Pkg.add(Pkg.PackageSpec(url="https://github.com/korbinian90/MRSI.jl"))
