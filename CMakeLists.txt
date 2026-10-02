# Author: Nathan Hanford

# Copyright (c) 2026 Lawrence Livermore National Security (LLNS), LLC.
# See COPYRIGHT file for more details.

# SPDX-License-Identifier: MIT
# See LICENSE file for more details

cmake_minimum_required(VERSION 3.21)

# Optional ROCM support
option(ENABLE_HIP "Enable ROCM support" OFF)

# Optional CUDA support
option(ENABLE_CUDA "Enable CUDA support" OFF)

set(BLT_CXX_STD "c++20")

project(MPIBenchmarks C CXX)

if (DEFINED BLT_SOURCE_DIR)
    # Support having a shared BLT outside of the repository if given a BLT_SOURCE_DIR
    if (NOT EXISTS ${BLT_SOURCE_DIR}/SetupBLT.cmake)
        message(FATAL_ERROR "Given BLT_SOURCE_DIR does not contain SetupBLT.cmake")
    endif()
else()
    # Use internal BLT if no BLT_SOURCE_DIR is given
    set(BLT_SOURCE_DIR "${CMAKE_SOURCE_DIR}/thirdparty/blt" CACHE PATH "Path to BLT")
    if (NOT EXISTS ${BLT_SOURCE_DIR}/SetupBLT.cmake)
        message(FATAL_ERROR
            "The BLT git submodule is not present. "
            "Either run the following two commands in your git repository: \n"
            "    git submodule init\n"
            "    git submodule update\n"
            "Or add -DBLT_SOURCE_DIR=/path/to/blt to your CMake command." )
    endif()
endif()
include(GNUInstallDirs)

find_package(umpire QUIET)

if(NOT umpire_FOUND)
    set(UMPIRE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/thirdparty/umpire")
    set(UMPIRE_ENABLE_TESTS OFF CACHE BOOL "Disable Umpire tests" FORCE)
    set(UMPIRE_ENABLE_BENCHMARKS OFF CACHE BOOL "Disable Umpire benchmarks" FORCE)
    set(UMPIRE_ENABLE_EXAMPLES OFF CACHE BOOL "Disable Umpire examples" FORCE)
    set(UMPIRE_ENABLE_DOCS OFF CACHE BOOL "Disable Umpire documentation" FORCE)
    set(UMPIRE_ENABLE_TOOLS OFF CACHE BOOL "Disable Umpire tools" FORCE)
    set(UMPIRE_ENABLE_C ON CACHE BOOL "Enable Umpire C API" FORCE)
    if(ENABLE_HIP)
        message(STATUS "Configuring Umpire with HIP support")
        set(UMPIRE_ENABLE_HIP ON CACHE BOOL "Enable HIP in Umpire" FORCE)
        set(UMPIRE_ENABLE_CUDA OFF CACHE BOOL "Disable CUDA in Umpire" FORCE)
    elseif(ENABLE_CUDA)
        message(STATUS "Configuring Umpire with CUDA support")
        set(UMPIRE_ENABLE_CUDA ON CACHE BOOL "Enable CUDA in Umpire" FORCE)
        set(UMPIRE_ENABLE_HIP OFF CACHE BOOL "Disable HIP in Umpire" FORCE)
    else()
        message(STATUS "Configuring Umpire without GPU support")
        set(UMPIRE_ENABLE_CUDA OFF CACHE BOOL "Disable CUDA in Umpire" FORCE)
        set(UMPIRE_ENABLE_HIP OFF CACHE BOOL "Disable HIP in Umpire" FORCE)
    endif()
    add_subdirectory(${UMPIRE_SOURCE_DIR} ${CMAKE_BINARY_DIR}/umpire EXCLUDE_FROM_ALL)
endif()

# Set default build type to Release
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Set compiler flags
set(CMAKE_C_FLAGS "-Wall")
set(CMAKE_C_FLAGS_RELEASE "-O3")

# Define source files
set(UTIL_SRC src/util.c)
set(BENCH_SRCS
    src/mpiBench.c
    src/mpiGraph.c
    src/sqmr.c
    src/com.c
)

# Configure GPU support
if(ENABLE_HIP)
    blt_add_library(
        NAME kernels
        SOURCES src/kernels.cpp
        DEPENDS_ON blt::hip
    )
    blt_add_library(
        NAME util
        SOURCES src/util.c
        HEADERS src/util.h
        DEPENDS_ON kernels blt::mpi umpire
        DEFINES ENABLE_HIP __HIP_PLATFORM_AMD__
    )
    set(CMAKE_HIP_FLAGS "${CMAKE_HIP_FLAGS} -Wall")
    set(CMAKE_HIP_FLAGS_RELEASE "-O3")
elseif(ENABLE_CUDA)
    blt_add_library(
        NAME kernels
        SOURCES src/kernels.cu
        DEPENDS_ON blt::cuda
    )
    blt_add_library(
        NAME util
        SOURCES src/util.c
        HEADERS src/util.h
        DEPENDS_ON kernels blt::mpi umpire
        DEFINES ENABLE_CUDA
    )
    set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xcompiler -Wall")
    set(CMAKE_CUDA_FLAGS_RELEASE "-O3")
else()
    blt_add_library(
        NAME util
        SOURCES src/util.c
        HEADERS src/util.h
        DEPENDS_ON blt::mpi umpire
    )
endif()

foreach(src ${BENCH_SRCS})
    get_filename_component(exec_name ${src} NAME_WE)
    blt_add_executable(
        NAME ${exec_name}
        SOURCES ${src}
        DEPENDS_ON util
    )
    install(TARGETS ${exec_name} DESTINATION bin)
endforeach()

option(DOCS "Build documentation" OFF)

if(DOCS)
    add_subdirectory(docs)

    # Create top-level docs target that depends on subdirectory targets
    add_custom_target(build-all-docs
        DEPENDS html man
        COMMENT "Building all documentation"
    )
endif()
