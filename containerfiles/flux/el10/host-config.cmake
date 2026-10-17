# Copyright (c) 2017-2025, Lawrence Livermore National Security, LLC and
# other BLT Project Developers. See the top-level LICENSE file for details
#
# SPDX-License-Identifier: (BSD-3-Clause)

# _blt_tutorial_compiler_config_start

set(CMAKE_C_COMPILER "/usr/bin/gcc" CACHE PATH "")

set(CMAKE_CXX_COMPILER "/usr/bin/g++" CACHE PATH "")

# Fortran support
set(ENABLE_FORTRAN OFF CACHE BOOL "")
set(CMAKE_Fortran_COMPILER "/usr/bin/gfortran" CACHE PATH "")
#_blt_tutorial_compiler_config_end

#------------------------------------------------------------------------------
# MPI Support
#------------------------------------------------------------------------------
# _blt_tutorial_mpi_config_start
set(ENABLE_MPI ON CACHE BOOL "")

set(MPI_HOME             "/usr/lib64/mpich" CACHE PATH "")

set(MPI_C_COMPILER       "${MPI_HOME}/bin/mpicc" CACHE PATH "")
set(MPI_CXX_COMPILER     "${MPI_HOME}/bin/mpicxx" CACHE PATH "")
set(MPI_Fortran_COMPILER "${MPI_HOME}/bin/mpif90" CACHE PATH "")

set(MPIEXEC              "/usr/bin/flux run" CACHE PATH "")
set(MPIEXEC_NUMPROC_FLAG "-n" CACHE PATH "")
# _blt_tutorial_mpi_config_end
