
----------------------------------
## sovabids/0.3.1a0 ##
Python sovabids environment with VScode 

This environment contains sovabids, a package for eeg to bids conversion.

Example:
```
source /opt/miniconda-4.7.12/etc/profile.d/conda.sh
conda activate sovabids
python
>>from sovabids.heuristics import from_io_example
>>sourcepath='data/lemon/V001/resting/010002.vhdr'
>>targetpath='data_bids/sub-010002/ses-001/eeg/sub-010002_ses-001_task-resting_eeg.vhdr'
>>print(from_io_example(sourcepath,targetpath))
```

More documentation can be found here: https://sovabids.readthedocs.io/en/latest/

----------------------------------
