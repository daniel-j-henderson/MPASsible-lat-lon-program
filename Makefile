FC = ifort
FFLAGS = -g -traceback -autodouble #-openmp
LDFLAGS = #-openmp

all: interp

interp: input.o output.o driver.o params.o
	$(FC) $(LDFLAGS) inputprocessing.o outputhandler.o params.o driver.o -o interp 
	
input.o: inputprocessing.f90 params.o
	$(FC) $(FFLAGS) -c inputprocessing.f90 -I${NETCDF}/include -L${NETCDF}/lib -lnetcdf

output.o: outputhandler.f90 params.o
	$(FC) $(FFLAGS) -c outputhandler.f90 -I${NETCDF}/include -L${NETCDF}/lib -lnetcdf
	
driver.o: driver.f90 params.o
	$(FC) $(FFLAGS) -c driver.f90 -I${NETCDF}/include -L${NETCDF}/lib -lnetcdf
	
params.o: params.f90 
	$(FC) $(FFLAGS) -c params.f90 -I${NETCDF}/include -L${NETCDF}/lib -lnetcdf

clean:
	rm *.o interp *.mod myNewFile.nc
