# MPASsible-lat-lon-program
This program does the MPASsible - now you can view your MPAS output on a lat-lon grid instantly! 
Just run the program to create the new interpolated netCDF file and then view it in ncview.


##DEFINITIONS
**MESH** - The term Mesh will generally refer to the MPAS SCVT mesh on which our data is found.

**GRID** - The term Grid will generally refer to the lat-lon grid onto which the MPAS variable data is interpolated.

**meshInfoFile** - This refers to the file which contains all the variables about the mesh's structure, like
                    cellsOnCell and xCell, for example.
                    
**meshDataFile** - This refers to the file which contains all the variables of scientific fields that we want to 
                    plot, like surface_pressure or qv. It should correspond to the Info file. If all info and data
                    can be found in the same file, then only one of these entries is required.

##HOW TO BUILD
Just make the makefile and you'll be fine

##HOW TO RUN
1. Edit the namelist called namelist.input
  - specify the height and width of the grid you want (2000x1000 is more than enough)
  - specify the range of latitudes and longitudes you'd like to see (note, due to the nature of lat-lon, there
    will be distortion around the poles.
  - you may specify 1 or 2 input files containing your desired MPAS variables*
  - you may specify the name of the output file*
  - you may specify the name of the desired MPAS variables*
  *can also be done from the command line
2. Supply optional command arguments to the executable "interp"
  - use **-v var1 var2 var3 ...** to add variables from the command line
  - use **-i filename** to supply the meshInfoFile from the command line
  - use **-d filename** to supply the meshDataFile from the command line
  - use **-o filename** to redirect the output file from the command line
