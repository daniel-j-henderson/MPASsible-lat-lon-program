

FC = ifort
FFLAGS = -g -traceback -autodouble
LDFLAGS = 




ifneq "$(NETCDF)" ""
        INCLUDES += -I$(NETCDF)/include
        LIBS += -L$(NETCDF)/lib
        NCLIB = -lnetcdf
        NCLIBF = -lnetcdff
        ifneq ($(wildcard $(NETCDF)/lib/libnetcdff.*), ) # CHECK FOR NETCDF4
                LIBS += $(NCLIBF)
        endif # CHECK FOR NETCDF4
        LIBS += $(NCLIB)
endif

ifort:
		( $(MAKE) all \
        "FC = ifort" \
        "FFLAGS = -g -traceback -autodouble" \
		"LDFLAGS = ")
		
gfortran:
		( $(MAKE) all \
        "FC = gfortran" \
        "FFLAGS =  -ffree-form --std=legacy -ffree-line-length-none -fdefault-real-8" \
		"LDFLAGS = ")	
		



all: interp

interp: input.o output.o driver.o params.o mesh_rotate.o
	$(FC) $(LDFLAGS) inputprocessing.o mesh_rotate.o outputhandler.o params.o driver.o -o interp $(INCLUDES) $(LIBS)
	
input.o: inputprocessing.f90 params.o
	$(FC) $(FFLAGS) -c inputprocessing.f90 $(INCLUDES) $(LIBS)

mesh_rotate.o: mesh_rotate.f90 params.o
	$(FC) $(FFLAGS) -c mesh_rotate.f90 $(INCLUDES) $(LIBS)
	
output.o: outputhandler.f90 params.o
	$(FC) $(FFLAGS) -c outputhandler.f90 $(INCLUDES) $(LIBS)
	
driver.o: driver.f90 mesh_rotate.o params.o 
	$(FC) $(FFLAGS) -c driver.f90 $(INCLUDES) $(LIBS)
	
params.o: params.f90 
	$(FC) $(FFLAGS) -c params.f90 $(INCLUDES) $(LIBS)

clean:
	rm *.o interp *.mod 
