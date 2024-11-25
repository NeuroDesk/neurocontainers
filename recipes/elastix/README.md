
----------------------------------
## elastix/5.1.0 ##

a toolbox for rigid and nonrigid registration of images.

elastix is open source software, based on the well-known Insight Segmentation and Registration Toolkit (ITK). The software consists of a collection of algorithms that are commonly used to perform (medical) image registration: the task of finding a spatial transformation, mapping one image (the fixed image) to another (the moving image), by optimizing relevant image similarity metrics. The modular design of elastix allows the user to quickly configure, test, and compare different registration methods for a specific application. A command-line interface enables automated processing of large numbers of data sets, by means of scripting. Nowadays elastix is accompanied by ITKElastix making it available in Python (on Pypi) and by SimpleElastix, making it available in languages like C++, Python, Java, R, Ruby, C# and Lua. 

Example:
```
examples and parameter files can be found here https://elastix.lumc.nl/modelzoo/
```


More documentation can be found here: https://github.com/SuperElastix/elastix/wiki

To make the executables and scripts inside this container transparently available in the command line of environments where Neurocommand is installed (without the need to use 'Apptainer exec'): ml elastix/5.1.0


Citation:
```
S. Klein, M. Staring, K. Murphy, M.A. Viergever, J.P.W. Pluim, "elastix: a toolbox for intensity based medical image registration," IEEE Transactions on Medical Imaging, vol. 29, no. 1, pp. 196 - 205, January 2010. 

D.P. Shamonin, E.E. Bron, B.P.F. Lelieveldt, M. Smits, S. Klein and M. Staring, "Fast Parallel Image Registration on CPU and GPU for Diagnostic Classification of Alzheimer’s Disease", Frontiers in Neuroinformatics, vol. 7, no. 50, pp. 1-15, January 2014. 

```

----------------------------------
