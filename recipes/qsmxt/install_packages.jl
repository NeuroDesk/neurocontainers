using Pkg
ENV["JULIA_PKG_PRECOMPILE_AUTO"]=0
Pkg.add(Pkg.PackageSpec(name="ArgParse", version=v"1.1.5"))
Pkg.add(Pkg.PackageSpec(name="FFTW", version=v"1.8.0"))
Pkg.add(Pkg.PackageSpec(name="MriResearchTools", version=v"2.2.0"))
Pkg.add(Pkg.PackageSpec(name="QuantitativeSusceptibilityMappingTGV", version=v"0.2.1"))
Pkg.add(Pkg.PackageSpec(name="ROMEO", version=v"1.1.1"))
Pkg.add(Pkg.PackageSpec(name="CLEARSWI", version=v"1.0.0"))
Pkg.add(Pkg.PackageSpec(name="QSM", version=v"0.5.4"))

