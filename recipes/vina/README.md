
----------------------------------
## AutoDock Vina/toolVersion ##
Docking and virtual screening program

AutoDock Vina is one of the fastest and most widely used open-source docking engines. It is a turnkey computational docking program that is based on a simple scoring function and rapid gradient-optimization conformational search. It was originally designed and implemented by Dr. Oleg Trott in the Molecular Graphics Lab, and it is now being maintained and develop by the Forli Lab at The Scripps Research Institute.

Example:
```
prepare_receptor
autogrid4
vina
vina_split
```

More documentation can be found here: https://autodock-vina.readthedocs.io/en/latest/

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed (without the need to use 'Apptainer exec'): ml vina/toolVersion

Citation:
```

```

----------------------------------
