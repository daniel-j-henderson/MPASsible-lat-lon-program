program latlondriver

	use inputprocessing
	use outputhandler
	use params
	use netcdf
	use mesh_rotate
	implicit none
	
	
	character(len=NF90_MAX_NAME), dimension(20) :: Variables = ' ', cmdVariables = ' '
	character(len=100) :: meshInfoFile = ' ', meshDataFile = ' ', outputfile = 'latlon.output.nc'
	character(len=600) :: commandarg
	character(len=NF90_MAX_NAME) :: var = ' '
	logical :: bothFiles = .false., infoOnly = .false., dataOnly = .false.
	integer :: l, n
	character (len = NF90_MAX_NAME), dimension(:), allocatable :: varstemp
	real :: original_latitude_degrees = 0.0, original_longitude_degrees = 0.0, new_latitude_degrees = 0.0, new_longitude_degrees = 0.0, birdseye_rotation_counter_clockwise_degrees = 0.0

	
	namelist /interpolator_settings/ Variables, meshInfoFile, meshDataFile, outputfile, gridW, gridH, gridHmin, gridHmax, gridWmin, gridWmax
	namelist /rotate_settings/ original_latitude_degrees, original_longitude_degrees, new_latitude_degrees, new_longitude_degrees, birdseye_rotation_counter_clockwise_degrees
	open(41,file='namelist.input') 
    read(41,interpolator_settings)
    read(41,rotate_settings)
    close(41)
    
    
    
    call get_command(commandarg, l, ierr)
	
	if(index(commandarg, '-v') > 0) then
		i = index(commandarg, '-v')
		i = i+2
		k=1
		do while(commandarg((i+1):(i+1)) /= '-' .and. commandarg((i+1):(i+2)) /= ' ')
			j=1
			do while(commandarg((i+j):(i+j)) /= ' ')
				var(j:j) = commandarg((i+j):(i+j))
				j=j+1
			end do
			cmdVariables(k) = var
			k = k+1
			var = ' '
			i = i+j
		end do
	end if
	
	if (index(commandarg, '-i') > 0) then
		meshInfoFile = ' '
		i = index(commandarg, '-i')
		i = i+3
		k = 1
		do while (commandarg(i:i) /= ' ')
			meshInfoFile(k:k) = commandarg(i:i)
			k = k+1
			i = i+1
		end do
	end if
	
	if (index(commandarg, '-d') > 0) then
		meshDataFile = ' '
		i = index(commandarg, '-d')
		i = i+3
		k = 1
		do while (commandarg(i:i) /= ' ')
			meshDataFile(k:k) = commandarg(i:i)
			k = k+1
			i = i+1
		end do
	end if
	
	if (index(commandarg, '-o') > 0) then
		outputfile = ' '
		i = index(commandarg, '-o')
		i = i+3
		k = 1
		do while (commandarg(i:i) /= ' ')
			outputfile(k:k) = commandarg(i:i)
			k = k+1
			i = i+1
		end do
	end if
		

    
    ! Determine if we have one or both files, and set the filenames accordingly
 	if (len_trim(meshInfoFile) > 0) then
 		if (len_trim(meshDataFile) > 0) then
 			bothFiles = .true.
 			filename = trim(meshInfoFile)
			filename2 = trim(meshDataFile)
 		else
 			infoOnly = .true.
 			filename = trim(meshInfoFile)
 			filename2 = trim(meshInfoFile)
 		end if
 	else if (len_trim(meshDataFile) > 0) then
 		dataOnly = .true.
 		filename = trim(meshDataFile)
 		filename2 = trim(meshDataFile)
 	else
 		write (0,*) 'You need to provide at least one input file either in the namelist'
 		write(0,*) 'variables "meshInfoFile" or "meshDataFile," or you can use the'
 		write(0,*) 'command line arguments -i or -d, respectively'
 		write(0,*) 'Program Terminated.'
 		stop
 	end if

	newFilename = trim(outputfile)
	
	
	k=size_of(cmdVariables)
	j=size_of(Variables)
	n = j + k
	if (n == 0) then
		write (0,*) 'You need to provide at least one desired variable either in the namelist'
		write(0,*) 'variable "Variables" (e.g. ''var1'', ''var2''...), or you can use the'
		write(0,*) 'command line argument -v'
 		write(0,*) 'Program Terminated.'
 		stop
 	end if
	
	
	!Extract the desired mesh variables from the Variables array
	
    allocate(varstemp(n))
    do i=1,j
    	varstemp(i) = trim(Variables(i))
    end do
    do i=j,n
    	if (i < n) then
    		varstemp(i+1) = trim(cmdVariables(i+1-j))
    	end if
    end do
    
    
    
    
	
	write(*,*) 'Opening Input'
    call open_input(filename, filename2)
	write(*,*) 'Running Setup'
    call setup()
    
    ! if (needs rotated), then call rotate(ncid, MeshX, MeshY, MeshZ, xVertex, yVertex, zVertex, xEdge, yEdge, zEdge, &
    ! original_latitude_degrees, original_longitude_degrees, new_latitude_degrees, new_longitude_degrees, birdseye_rotation_counter_clockwise_degrees)
    
    if (needs_rotated(original_latitude_degrees, original_longitude_degrees, new_latitude_degrees, new_longitude_degrees, birdseye_rotation_counter_clockwise_degrees)) then
    	call rotate(ncid, MeshX, MeshY, MeshZ, xVertex, yVertex, zVertex, xEdge, yEdge, zEdge, &
                    original_latitude_degrees, original_longitude_degrees, new_latitude_degrees, new_longitude_degrees, birdseye_rotation_counter_clockwise_degrees)
    end if
    
    write(*,*) 'Checking for existence of variables, throwing out any for which there is no input data.'
    call check_existence(varstemp)
	write(*,*) 'Interpolating data for variables:', desiredMeshVars
    write(*,*) 'Creating Grid Map'
    call create_grid_map(grid)
    write(*,*) 'Creating Output File'
    call create_output_file(newFilename)
    
    
	write(*,*) 'Determining Dimensionality'
    call dimensionality(desiredMeshVars)

	!For each desired mesh variable, based on its dimension call the appropriate routine
	!to put the data in the output file
	do i = 1, nMeshVars
		if (nDims(i) == 1) then
			call put_data1(meshVarIDs(i), meshDimIDs(i,1), gridVarIDs(i))
		else if (nDims(i) == 2) then
			call put_data2(meshVarIDs(i), meshDimIDs(i,:), gridVarIDs(i))
		else if (nDims(i) == 3) then
			call put_data3(meshVarIDs(i), meshDimIDs(i,:), gridVarIDs(i))
    	end if
    end do
    
	write(*,*) 'Cleaning Up'
    call clean_up()
    deallocate(desiredMeshVars)
    
    write(*,*) 'Successfully interpolated all your desired variables onto a lat-lon grid'
end program latlondriver