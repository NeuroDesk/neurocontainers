curl -s https://github.com/Neurodesk/caid/packages | sed -n "s/^.*\/NeuroDesk\/caid\/packages\/.*>\(.*\)\(\S*\)<\/a>$/\1/p"
