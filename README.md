# How to build SAD
Main Trunk(1.0.9b or later)
Copy sad.conf.sample to sad.conf and edit it.
Usable configuration variable is shown below.

SAD_ROOT      define SAD install prefix, if you need to instal.
USE_X11       define as `YES', if you want to link X11 library.
USE_TCLTK     define as `YES', if you want to link Tcl/Tk.
       
CAUTION:
Now X11 and Tcl/Tk linkage glue depend each other.
You must set USE_TCLTK = USE_X11.

If you don’t want Tcl/Tk or Python linkage, you can skip this step.
Choose either getting archives by yourself(a) or using automatic fetch(b).

a. Put 3rd party source archives into oldsad/distfiles directory.
   (Ex. tcl8.5a5-src.tar.gz, tk8.5a5-src.tar.gz)
b. Install GNU/wget utility or set URI fetch command to FETCH variable,
   if you don't use 4.4BSD-Lite variant.
   (BSD extended ftp(1) is used on 4.4BSD-Lite variant)
       
Run `make depend’ on oldsad directory, if you modify sources.
Run `make all’ on oldsad directory.
Run `make install’, if you want install to SAD_ROOT.
CAUTION:
SAD source tree need GNU make utility and C/Fortran compiler chain to build.
In the some environment, you have to install such tool chains.

OS Support Status
Main trunk(original version)
Tier-1(maintained for SuperKEKB design/simulation)
FreeBSD/amd64 8.2-STABLE
MacOS X/i386 10.5.x

