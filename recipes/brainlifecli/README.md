
----------------------------------
## brainlifecli/toolVersion ##
With brainlife CLI, you can ..

Upload/download data from your computer.
Upload data stored in BIDS format.
Submit Apps, and monitor (you can fully script data processing through brainlife)
Query projects, data, datatypes, etc.

Example:
```
bl login --ttl 7
bl project query --help
bl data upload --help
```

More documentation can be found here: https://brainlife.io/docs/cli/install/

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml brainlifecli/toolVersion

Citation:
```
Hayashi, S., Caron, B.A., Heinsfeld, A.S. et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. Nat Methods (2024). https://doi.org/10.1038/s41592-024-02237-2
```

License: MIT, https://github.com/brainlife/cli?tab=MIT-1-ov-file#readme

----------------------------------
