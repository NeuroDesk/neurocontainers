
----------------------------------
## root/6.22.02 ##
ROOT is a powerful software framework, an open source project coordinated by the European Organisation for Nuclear Research, CERN in Geneva.

ROOT is very flexible and provides both a programming interface to use in own applications and a graphical user interface for interactive data analysis. ROOT leads a double life. It has an interpreter for macros (Cling) that you can run from the command line or run like applications. But it is also an interactive shell that can evaluate arbitrary statements and expressions. This is extremely useful for debugging, quick hacking and testing. Let us first have a look at some very simple examples.

start the root shell with the command 'root', try things like 'TMath::Pi()'

or plotting a function
```
root [11] TF1 f1("f1","sin(x)/x",0.,10.);
root [12] f1.Draw();
```

More documentation can be found here: https://root.cern/primer/

To run applications outside of this container: ml root/6.22.02

----------------------------------
