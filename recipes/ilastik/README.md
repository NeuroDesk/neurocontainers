
----------------------------------
## ilastik/toolVersion ##
ilastik is a simple, user-friendly tool for interactive image classification, segmentation and analysis. It is built as a modular software framework, which currently has workflows for automated (supervised) pixel- and object-level classification, automated and semi-automated object tracking, semi-automated segmentation and object counting without detection. Most analysis operations are performed lazily, which enables targeted interactive processing of data subvolumes, followed by complete volume analysis in offline batch mode. Using it requires no experience in image processing.

Example:
```
run_ilastik.sh
```

More documentation can be found here:  https://www.ilastik.org/documentation/index.html

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed: ml ilastik/toolVersion

Citation:
```
ilastik: interactive machine learning for (bio)image analysis
Stuart Berg, Dominik Kutra, Thorben Kroeger, Christoph N. Straehle, Bernhard X. Kausler, Carsten Haubold, Martin Schiegg, Janez Ales, Thorsten Beier, Markus Rudy, Kemal Eren, Jaime I Cervantes, Buote Xu, Fynn Beuttenmueller, Adrian Wolny, Chong Zhang, Ullrich Koethe, Fred A. Hamprecht & Anna Kreshuk
in: Nature Methods, (2019) 
```

----------------------------------
