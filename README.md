# MPASsible-lat-lon-program
This program does the MPASsible - now you can view your MPAS output on a lat-lon grid instantly! 
Just run the program to create the new interpolated netCDF file and then view it in ncview.


##DEFINITIONS
**MESH** - The term Mesh will generally refer to the MPAS SCVT mesh on which our data is found.

**GRID** - The term Grid will generally refer to the lat-lon grid onto which the MPAS variable data is interpolated.

**meshInfoFile** - This refers to the file which contains all the variables about the mesh's structure, like
                    cellsOnCell and xCell, for example.
                    
**meshDataFile** - This refers to the file which contains all the variables of scientific fields that we want to 
                    plot, like surface_pressure or qv. It should correspond to the Info file (i.e. have the same mesh size/resolution/etc.). If all info and data
                    can be found in the same file, then only one of these entries is required.

**SPATIAL DIMENSION** - This refers to the dimensions nCells, nEdges, and nVertices. Without one of these, there is nothing to interpolate.

##HOW TO BUILD
Just make the makefile with your preferred compiler as the target (I support ifort or gfortran right now), e.g. 'make gfortran'.

##HOW TO RUN
1. Edit the namelist called namelist.input
  - specify the height and width of the grid you want (2000x1000 is more than enough)
  - specify the range of latitudes and longitudes you'd like to see (note, due to the nature of lat-lon, there
    will be distortion around the poles.
  - specify what rotation settings you'd like, if any. This is the same idea as the grid_rotate program popular with MPAS meshes
  - you may specify 1 or 2 input files containing your desired MPAS variables*
  - you may specify the name of the output file*
  - you may specify the name of the desired MPAS variables (up to 20)*

  *can also be done from the command line
2. Supply optional command arguments to the executable "interp"
  - use **-v var1 var2 var3 ...** to add variables from the command line
  - use **-i filename** to supply the meshInfoFile from the command line
  - use **-d filename** to supply the meshDataFile from the command line
  - use **-o filename** to redirect the output file from the command line
  
##REQUIREMENTS
  - This version supports up to 20 variables.
  - This version supports 6 MPAS dimensions: nCells, nVertices, nEdges, Time, nVertLevels, nSoilLevels.
  - MPAS syntax must be used in all input files. 
  - The each variable must be dimensioned at least by one and only one spatial dimension. 

##NOTES
  - For large meshes with large, multidimensional variables, the data for one variable at every time/vertical level may be too large to hold in memory, so these variables will be tackled in slices, one slice per (time)(vertlevel). 
  - The execution time generally scales more drastically with grid size than mesh size, so for optimal speed (on the order of a few seconds or less), choose a coarser grid (your monitor is only so large anyways). 
  - That being said, a mesh with over 65 million cells does take around 15 seconds to import all the mesh info into memory, so expect some overhead for very fine meshes.
  - For help with rotation settings, read about it in the grid_rotate source code here (https://mpas-dev.github.io/atmosphere/atmosphere_meshes.html)
