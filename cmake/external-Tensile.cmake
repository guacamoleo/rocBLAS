# ########################################################################
# Copyright 2016 Advanced Micro Devices, Inc.
# ########################################################################

# Downloads and builds Tensile. Defines:
# Tensile_INCLUDE_DIRS
# TensileLib_LIBRARIES
# TensileLogger_LIBRARIES

message( STATUS "Configuring Tensile external dependency" )
include( ExternalProject )

set( Tensile_REPO "https://github.com/clMathLibraries/Tensile.git"
    CACHE STRING "URL to download Tensile from" )
set( Tensile_TAG "develop" CACHE STRING "Tensile branch to download" )

option( Tensile_ENABLE_LOGGER "Enable logger in Tensile?" OFF )

include( ProcessorCount )
ProcessorCount( Cores )
if( NOT Cores EQUAL 0 )
  # Travis can fail to build Boost sporadically; uses 32 cores, reduce stress on VM
  if( DEFINED ENV{TRAVIS} )
    if( Cores GREATER 8 )
      set( Cores 8 )
    endif( )
  endif( )

  # Add build thread in addition to the number of cores that we have
  math( EXPR Cores "${Cores} + 1 " )
else( )
  # If we could not detect # of cores, assume 1 core and add an additional build thread
  set( Cores "2" )
endif( )

message( "Building Tensile with ${Cores} cores" )

# TODO rocBLAS clients to use logger and write XMLs to build dir, not src
ExternalProject_Add(
  Tensile
  GIT_REPOSITORY ${Tensile_REPO}
  GIT_TAG ${Tensile_TAG}
  PREFIX ${CMAKE_BINARY_DIR}/extern/Tensile
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>/package
  LOG_BUILD 1
)

set_property( TARGET Tensile PROPERTY FOLDER "extern")
ExternalProject_Get_Property( Tensile install_dir )

# For use by the user of external-Tensile.cmake
set( Tensile_ROOT ${install_dir}/package )