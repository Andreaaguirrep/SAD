# How to Build SAD

## Main Trunk (1.0.9b or later)

1. Copy `sad.conf.sample` to `sad.conf` and edit it.  
   Usable configuration variables are shown below:

SAD_ROOT define SAD install prefix, if you need to install. 

USE_X11 define as YES, if you want to link X11 library. 

USE_TCLTK define as YES, if you want to link Tcl/Tk.


**CAUTION:**  
Now X11 and Tcl/Tk linkage due depend on each other.  
You must set `USE_TCLTK = USE_X11`.

2. If you don’t want Tcl/Tk or Python linkage, you can skip this step.  
Choose either getting archives by yourself (a) or using automatic fetch (b).

a. Put 3rd party source archives into oldsad/distfiles directory. (Ex. tcl8.5a5-src.tar.gz, tk8.5a5-src.tar.gz)

b. Install GNU/wget utility or set URI fetch command to FETCH variable, if you don't use 4.4BSD-Lite variant. (BSD extended ftp(1) is used on 4.4BSD-Lite variant)


3. Run `make depend` on `oldsad` directory, if you modify sources.  
4. Run `make all` on `oldsad` directory.  
5. Run `make install`, if you want to install to `SAD_ROOT`.

### CAUTION
SAD source tree needs GNU make utility and C/Fortran compiler chain to build.  
In some environments, you have to install such tools.

