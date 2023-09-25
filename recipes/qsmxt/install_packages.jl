using Pkg
packages = ["ArgParse", "FFTW", "QSM"]
Pkg.add(packages)
Pkg.add(Pkg.PackageSpec(name="MriResearchTools", version=v"2.2.0"))
Pkg.add(Pkg.PackageSpec(url="https://github.com/korbinian90/RomeoApp.jl"))
Pkg.add(Pkg.PackageSpec(url="https://github.com/korbinian90/QuantitativeSusceptibilityMappingTGV.jl", rev="8ce83eaef34635a6f69dc254653b390929181bd1"))
Pkg.add(Pkg.PackageSpec(name="CLEARSWI", version=v"1.0.0"))
