using Pkg
ENV["JULIA_PKG_PRECOMPILE_AUTO"]=0
packages = ["ArgParse", "FFTW", "QSM"]
Pkg.add(packages)
Pkg.add(Pkg.PackageSpec(name="MriResearchTools", version=v"2.2.0"))
Pkg.add(Pkg.PackageSpec(name="QuantitativeSusceptibilityMappingTGV", version=v"0.2.1"))
Pkg.add(Pkg.PackageSpec(url="https://github.com/korbinian90/RomeoApp.jl"))
Pkg.add(Pkg.PackageSpec(name="CLEARSWI", version=v"1.0.0"))
