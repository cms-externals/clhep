#
# clhep_set_compiler_flags() 
#    sets the default compiler flags
#    calls clhep_autoconf_variables
#
# clhep_autoconf_variables() defines global variables
#
# clhep_package_config():
#    defines ${PACKAGE}_LIBS
#    processes ${PACKAGE}-config.in
#    processes ${PACKAGE}-deps.in
#
# clhep_package_config_no_lib():
#    processes ${PACKAGE}-config.in
#
# clhep_config():
#    processes clhep-config.in
#
# clhep_lib_suffix();
#    check for -DLIB_SUFFIX=xxx and process intelligently
#

macro( clhep_check_variable_names )
  # useful if you need to check a variable
  message( STATUS "clhep_check_variable_names: CMAKE_SYSTEM_NAME is ${CMAKE_SYSTEM_NAME}" )
  message( STATUS "clhep_check_variable_names: CMAKE_BASE_NAME is ${CMAKE_BASE_NAME}" )
  message( STATUS "clhep_check_variable_names: CMAKE_CXX_COMPILER_ID is ${CMAKE_CXX_COMPILER_ID}" )
  message( STATUS "clhep_check_variable_names: CMAKE_COMPILER_IS_GNUCXX is ${CMAKE_COMPILER_IS_GNUCXX}" )
  message( STATUS "clhep_check_variable_names: CMAKE_COMPILER_IS_MINGW is ${CMAKE_COMPILER_IS_MINGW}" )
  message( STATUS "clhep_check_variable_names: CMAKE_COMPILER_IS_CYGWIN is ${CMAKE_COMPILER_IS_CYGWIN}" )
  message( STATUS "clhep_check_variable_names: CMAKE_AR is ${CMAKE_AR}" )
  message( STATUS "clhep_check_variable_names: CMAKE_RANLIB is ${CMAKE_RANLIB}" )
  message( STATUS "clhep_check_variable_names: CMAKE_CXX_OUTPUT_EXTENSION is ${CMAKE_CXX_OUTPUT_EXTENSION}" )
  message( STATUS "clhep_check_variable_names: CMAKE_SHARED_LIBRARY_CXX_FLAGS is ${CMAKE_SHARED_LIBRARY_CXX_FLAGS}" )
  message( STATUS "clhep_check_variable_names: CMAKE_SHARED_MODULE_CXX_FLAGS is ${CMAKE_SHARED_MODULE_CXX_FLAGS}" )
  message( STATUS "clhep_check_variable_names: CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS is ${CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS}" )
  message( STATUS "clhep_check_variable_names: CMAKE_CXX_FLAGS is ${CMAKE_CXX_FLAGS}" )
  message( STATUS "clhep_check_variable_names: CMAKE_CXX_FLAGS_DEBUG is ${CMAKE_CXX_FLAGS_DEBUG}" )
  message( STATUS "clhep_check_variable_names: CMAKE_CXX_FLAGS_RELEASE is ${CMAKE_CXX_FLAGS_RELEASE}" )
  message( STATUS "clhep_check_variable_names: CMAKE_CXX_FLAGS_RELWITHDEBINFO is ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" )
  message( STATUS "clhep_check_variable_names: CMAKE_CXX_STANDARD_LIBRARIES is ${CMAKE_CXX_STANDARD_LIBRARIES}" )
  message( STATUS "clhep_check_variable_names: CMAKE_CXX_LINK_FLAGS is ${CMAKE_CXX_LINK_FLAGS}" )
endmacro( clhep_check_variable_names )

macro( clhep_autoconf_variables )

  # these variables are used by <package>-config.in
  # typical values from autoconf:
  #   AM_CXXFLAGS = -O -ansi -pedantic -Wall -D_GNU_SOURCE
  #   CXXFLAGS = -g -O2
  #   CXX = g++
  #   CXXCPP = g++ -E
  #   CPPFLAGS = 
  #   CXXLD = $(CXX)
  #   AM_LDFLAGS = 
  #   LDFLAGS = 
  #   LIBS = 

  # automake/autoconf variables
  set( prefix      ${CMAKE_INSTALL_PREFIX} )
  set( exec_prefix "\${prefix}" )
  set( includedir  "\${prefix}/include" )
  set( configure_input "Generated by cmake" )

  ### autoconf variables typically do not have the path
  set( CXX ${CMAKE_BASE_NAME} )
  set( CXXCPP       "${CXX} -E" )
  if( ${CMAKE_BUILD_TYPE} MATCHES "Debug" )
     set( CXXFLAGS  ${CMAKE_CXX_FLAGS_DEBUG} )
  elseif( ${CMAKE_BUILD_TYPE} MATCHES "Release" )
     set( CXXFLAGS  ${CMAKE_CXX_FLAGS_RELEASE} )
  elseif( ${CMAKE_BUILD_TYPE} MATCHES "RelWithDebInfo" )
     set( CXXFLAGS  ${CMAKE_CXX_FLAGS_RELWITHDEBINFO} )
  elseif( ${CMAKE_BUILD_TYPE} MATCHES "MinSizeRel" )
     set( CXXFLAGS  ${CMAKE_CXX_FLAGS_MINSIZEREL} )
  endif()
  ##message( STATUS "build type ${CMAKE_BUILD_TYPE} has ${CXXFLAGS}")
  set( AM_CXXFLAGS  ${CMAKE_CXX_FLAGS} )
  set( LDFLAGS      ${CMAKE_MODULE_LINKER_FLAGS} )
  set( LIBS         "" )
  set( DIFF_Q       "diff -q -b" )

  if( CLHEP_DEBUG_MESSAGES )
    clhep_check_variable_names()
  endif()

endmacro( clhep_autoconf_variables )

macro( _clhep_verify_cxx11 )
  if( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang" )
    if( CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.3 )
      message( FATAL_ERROR "c++11 extension is not available for ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
    else()
      set( HAVE_STDCXX true )
    endif()
  elseif( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Intel" )
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 14.0)
      message( FATAL_ERROR "c++11 extension is not available for ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
    else()
      set( HAVE_STDCXX true )
    endif()
  elseif(CMAKE_COMPILER_IS_GNUCXX)
    if( CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8 )
      message( FATAL_ERROR "CLHEP now requires c++11 support with gcc 4.8 or later")
    else()
      set( HAVE_STDCXX true )
    endif()
  else()
    message(STATUS "clhep_set_compiler_flags: Do not know how to set c++11 extensions for ${CMAKE_CXX_COMPILER_ID}")
  endif()
endmacro( _clhep_verify_cxx11 )

macro( _clhep_verify_cxx1y )
  if( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang" )
    if( CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.5 )
      message( FATAL_ERROR "c++1y extension is not available for ${CMAKE_CXX_COMPILER_ID}${CMAKE_CXX_COMPILER_VERSION}")
    else()
      set( HAVE_STDCXX true )
    endif()
  elseif( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Intel" )
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 15.0)
      message( FATAL_ERROR "c++11 extension is not available for ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
    else()
      set( HAVE_STDCXX true )
    endif()
  elseif(CMAKE_COMPILER_IS_GNUCXX)
    if( CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9 )
      message( FATAL_ERROR "c++1y extension is not available for ${CMAKE_CXX_COMPILER}")
    else()
      set( HAVE_STDCXX true )
    endif()
  else()
    message(STATUS "clhep_set_compiler_flags: Do not know how to set c++1y extensions for ${CMAKE_CXX_COMPILER_ID}")
  endif()
endmacro( _clhep_verify_cxx1y )

macro( _clhep_verify_cxx14 )
  if( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang" )
    if( CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.5 )
      message( FATAL_ERROR "c++14 extension is not available for ${CMAKE_CXX_COMPILER_ID}${CMAKE_CXX_COMPILER_VERSION}")
    else()
      set( HAVE_STDCXX true )
    endif()
  elseif( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Intel" )
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 16.0)
      message( FATAL_ERROR "c++14 extension is not available for ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
    else()
      set( HAVE_STDCXX true )
    endif()
  elseif(CMAKE_COMPILER_IS_GNUCXX)
    if( CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9 )
      message( FATAL_ERROR "c++14 extension is not available for ${CMAKE_CXX_COMPILER}")
    else()
      set( HAVE_STDCXX true )
    endif()
  else()
    message(STATUS "clhep_set_compiler_flags: Do not know how to set c++14 extensions for ${CMAKE_CXX_COMPILER_ID}")
  endif()
endmacro( _clhep_verify_cxx14 )

macro( _clhep_check_cxxstd )
  if( CLHEP_DEBUG_MESSAGES )
    message(STATUS "_clhep_check_cxxstd debug: CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}")
    message(STATUS "_clhep_check_cxxstd debug: CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")
    message(STATUS "_clhep_check_cxxstd debug: CMAKE_CXX_COMPILER_VERSION: ${CMAKE_CXX_COMPILER_VERSION}")
    message(STATUS "_clhep_check_cxxstd debug: CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
    message(STATUS "_clhep_check_cxxstd debug: CLHEP_BUILD_CXXSTD: ${CLHEP_BUILD_CXXSTD}")
  endif( CLHEP_DEBUG_MESSAGES )
  set( HAVE_STDCXX )
  if( "${CLHEP_BUILD_CXXSTD}" STREQUAL "-std=c++0x" )
    message( FATAL_ERROR "The c++0x extension is no longer supported.  Please use c++11 or later.")
  elseif( "${CLHEP_BUILD_CXXSTD}" STREQUAL "-std=c++11" )
    _clhep_verify_cxx11()
  elseif( "${CLHEP_BUILD_CXXSTD}" STREQUAL "-std=c++1y" )
    _clhep_verify_cxx1y()
  elseif( "${CLHEP_BUILD_CXXSTD}" STREQUAL "-std=c++14" )
    _clhep_verify_cxx14()
  elseif( DEFINED CLHEP_BUILD_CXXSTD )
    message( FATAL_ERROR "${CLHEP_BUILD_CXXSTD} is not supported.  Supported extensions are c++11, c++1y, and c++14.")
  else()
    # presume -std=c++11
    set(CLHEP_BUILD_CXXSTD "-std=c++11")
    _clhep_verify_cxx11( )
  endif()
  ##message(STATUS "_clhep_check_cxxstd debug: CLHEP_BUILD_CXXSTD HAVE_STDCXX: ${CLHEP_BUILD_CXXSTD} ${HAVE_STDCXX}")
  if( DEFINED HAVE_STDCXX )
    if( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang" )
	set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CLHEP_BUILD_CXXSTD} -pthread" )
    elseif( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Intel" )
	set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CLHEP_BUILD_CXXSTD} -pthread" )
    elseif(CMAKE_COMPILER_IS_GNUCXX)
	set( CMAKE_CXX_FLAGS "${CLHEP_BUILD_CXXSTD} -pthread ${CMAKE_CXX_FLAGS} -D_GNU_SOURCE" )
    else()
      message(STATUS "clhep_set_compiler_flags: Do not know how to set ${CLHEP_BUILD_CXXSTD} extensions for ${CMAKE_CXX_COMPILER_ID}")
    endif()
  endif()
endmacro( _clhep_check_cxxstd )

macro( _clhep_check_for_pthread )
  message( FATAL_ERROR "_clhep_check_for_pthread should no longer be used. CLHEP now requires gcc 4.8 or later with c++11 or later.")
  ##message(STATUS "_clhep_check_for_pthread debug: CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
  set( HAVE_STDCXX )
  if( NOT "${CMAKE_CXX_FLAGS}" STREQUAL "" )
    string(REGEX REPLACE " " ";" flag_list ${CMAKE_CXX_FLAGS})
    FOREACH(flag ${flag_list})    
       #message(STATUS "_clhep_check_for_pthread debug: found flag ${flag}" )
       if( ${flag} STREQUAL "-std=c++0x" )
	 message( FATAL_ERROR "CLHEP must be built with c++11 or later enabled")
       elseif( ${flag} STREQUAL "-std=c++11" )
         _clhep_verify_cxx11()
       elseif( ${flag} STREQUAL "-std=c++1y" )
         _clhep_verify_cxx1y()
       elseif( ${flag} STREQUAL "-std=c++14" )
         _clhep_verify_cxx14()
       endif()
       message(STATUS "${flag} ${HAVE_STDCXX}")
    ENDFOREACH(flag)
    if( DEFINED HAVE_STDCXX )
	set( CMAKE_CXX_FLAGS "-pthread ${CMAKE_CXX_FLAGS}" )
    endif()
    #message(STATUS "_clhep_check_for_pthread debug: HAVE_STDCXX ${HAVE_STDCXX}")
    message(STATUS "_clhep_check_for_pthread debug: CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
  endif()
endmacro( _clhep_check_for_pthread )

macro( clhep_set_compiler_flags )
  ##message(STATUS "incoming cmake build type is ${CMAKE_BUILD_TYPE}")
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "" FORCE)
  endif()
  ##message(STATUS "clhep_set_compiler_flags debug: CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
  message(STATUS "cmake build type is ${CMAKE_BUILD_TYPE}")
  #if( CLHEP_BUILD_CXXSTD )
     _clhep_check_cxxstd()
     message(STATUS "enable c++11 extensions: ${CMAKE_CXX_FLAGS}")
  #else()
  #   _clhep_check_for_pthread()
  #endif()
  if( CLHEP_DEBUG_MESSAGES )
    message(STATUS "clhep_set_compiler_flags debug: CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
    message(STATUS "clhep_set_compiler_flags debug: cmake compilers ${CMAKE_CXX_COMPILER} ${CMAKE_C_COMPILER}")
  endif( CLHEP_DEBUG_MESSAGES )
  get_filename_component(clhep_cxx_compiler ${CMAKE_CXX_COMPILER} NAME)
  get_filename_component(clhep_c_compiler ${CMAKE_C_COMPILER} NAME)
  if( CLHEP_DEBUG_MESSAGES )
    message(STATUS "using compilers ${clhep_cxx_compiler} ${clhep_c_compiler}")
  endif( CLHEP_DEBUG_MESSAGES )
  if( ${clhep_c_compiler} STREQUAL "clang" )
    set(CMAKE_C_FLAGS "-O -pedantic -Wall ${CMAKE_C_FLAGS}")
  elseif( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Intel" )
    set(CMAKE_C_FLAGS "-O -ansi -pedantic -Wall {CMAKE_C_FLAGS}")
    set(CMAKE_CXX_FLAGS "-O -ansi -pedantic -Wall ${CMAKE_CXX_FLAGS}")
  elseif( CMAKE_COMPILER_IS_GNUCC )
    set(CMAKE_C_FLAGS "-O -ansi -pedantic -Wall -D_GNU_SOURCE ${CMAKE_C_FLAGS}")
  endif()
  if( ${clhep_cxx_compiler} STREQUAL "clang++" )
    set(CMAKE_CXX_FLAGS "-O -pedantic -Wall ${CMAKE_CXX_FLAGS}")
  elseif(CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS "-O -ansi -pedantic -Wall -D_GNU_SOURCE ${CMAKE_CXX_FLAGS}")
  endif()
  if( ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
    ##message( STATUS "system is Windows" )
    ##message( STATUS "CMAKE_BASE_NAME is ${CMAKE_BASE_NAME}" )
    if( ${CMAKE_BASE_NAME} MATCHES "cl" )
      ##message( STATUS "compiler is MSVC" )
      ##message( STATUS "incoming basic compiler flags are ${CMAKE_CXX_FLAGS}")
      set(CMAKE_C_FLAGS "/EHsc /nologo /GR /MD /D USING_VISUAL")
      set(CMAKE_CXX_FLAGS "/EHsc /nologo /GR /MD /D USING_VISUAL")
    endif()
  endif()
  clhep_autoconf_variables()
  message( STATUS "compiling with ${clhep_cxx_compiler} ${CMAKE_CXX_FLAGS} ${CXXFLAGS}")
endmacro( clhep_set_compiler_flags )

macro( clhep_package_config_no_lib )
  set( ${PACKAGE}_CPPFLAGS "-I${includedir}" )
  set( ${PACKAGE}_LDFLAGS  " " )
  set( ${PACKAGE}_LIBS     " " )
  configure_file ( ${CLHEP_SOURCE_DIR}/${PACKAGE}/${PACKAGE}-config.in
                   ${CLHEP_BINARY_DIR}/${PACKAGE}/${PACKAGE}-config @ONLY )
  ## don't install <package>-config on Windows
  if( NOT ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
    install ( PROGRAMS ${CLHEP_BINARY_DIR}/${PACKAGE}/${PACKAGE}-config
              DESTINATION bin
	    )
  endif()
endmacro( clhep_package_config_no_lib )

macro( clhep_package_config )
  set( ${PACKAGE}_CPPFLAGS "-I${includedir}" )
  set( ${PACKAGE}_LDFLAGS  "-L\${exec_prefix}/lib${LIB_SUFFIX}" )
  set( ${PACKAGE}_LIBS     "-lCLHEP-${PACKAGE}-${VERSION}" )
  if( ${PACKAGE}_DEPS )
     foreach ( dep ${${PACKAGE}_DEPS} )
        message( STATUS "${PACKAGE} depends on ${dep}")
	set( ${PACKAGE}_LIBS     "${${PACKAGE}_LIBS} -lCLHEP-${dep}-${VERSION}" )
     endforeach()
  endif()
  configure_file ( ${CLHEP_SOURCE_DIR}/${PACKAGE}/${PACKAGE}-config.in
                   ${CLHEP_BINARY_DIR}/${PACKAGE}/${PACKAGE}-config @ONLY )
  configure_file ( ${CLHEP_SOURCE_DIR}/${PACKAGE}/${PACKAGE}-deps.in
                   ${CLHEP_BINARY_DIR}/${PACKAGE}/${PACKAGE}-deps @ONLY )
  ## don't install <package>-config on Windows
  if( NOT ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
    install ( PROGRAMS ${CLHEP_BINARY_DIR}/${PACKAGE}/${PACKAGE}-config
              DESTINATION bin
	    )
  endif()
endmacro( clhep_package_config )

macro( clhep_config )
  configure_file ( ${CLHEP_SOURCE_DIR}/clhep-config.in
                   ${CLHEP_BINARY_DIR}/clhep-config @ONLY )
  ## don't install clhep-config on Windows
  if( NOT ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
    install ( PROGRAMS ${CLHEP_BINARY_DIR}/clhep-config
              DESTINATION bin
	    )
  endif()
endmacro( clhep_config )

macro( _clhep_lib_suffix_64 )
  if( APPLE )
    #message(STATUS "checking LIB_SUFFIX ${LIB_SUFFIX} against ${CMAKE_SYSTEM_PROCESSOR} and ${CMAKE_OSX_ARCHITECTURES}")
    # On Mac, we use NAME-ARCH, but ARCH is 'Universal' if more than
    # one arch is built for. Note that falling back to use
    # CMAKE_SYSTEM_PROCESSOR may *not* be 100% reliable.
    list(LENGTH CMAKE_OSX_ARCHITECTURES _number_of_arches)
    if(NOT _number_of_arches)
      # - Default
      if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
        # building for 64bit
      else()
        message(STATUS "WARNING: LIB_SUFFIX ${LIB_SUFFIX} inappropriate for this build")
	set(LIB_SUFFIX "")
      endif()
    elseif(_number_of_arches GREATER 1)
      # - Universal
    else()
      # - Use what the user specified
      if (${CMAKE_OSX_ARCHITECTURES} STREQUAL "x86_64")
        # building for 64bit
      else()
        message(STATUS "WARNING: LIB_SUFFIX ${LIB_SUFFIX} inappropriate for this build")
	set(LIB_SUFFIX "")
      endif()
    endif()
  elseif( ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
    #message(STATUS "checking LIB_SUFFIX ${LIB_SUFFIX} against ${CMAKE_SYSTEM_PROCESSOR} ")
    if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86")
      # building for 64bit
    else()
      message(STATUS "WARNING: LIB_SUFFIX ${LIB_SUFFIX} inappropriate for this build")
      set(LIB_SUFFIX "")
    endif()
  else()
    #message(STATUS "checking LIB_SUFFIX ${LIB_SUFFIX} against ${CMAKE_SYSTEM_PROCESSOR} ")
    if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
      # building for 64bit
    else()
      message(STATUS "WARNING: LIB_SUFFIX ${LIB_SUFFIX} inappropriate for this build")
      set(LIB_SUFFIX "")
    endif()
  endif()
endmacro( _clhep_lib_suffix_64 )

macro( _clhep_lib_suffix_32 )
  if( APPLE )
    #message(STATUS "checking LIB_SUFFIX ${LIB_SUFFIX} against ${CMAKE_SYSTEM_PROCESSOR} and ${CMAKE_OSX_ARCHITECTURES}")
    # On Mac, we use NAME-ARCH, but ARCH is 'Universal' if more than
    # one arch is built for. Note that falling back to use
    # CMAKE_SYSTEM_PROCESSOR may *not* be 100% reliable.
    list(LENGTH CMAKE_OSX_ARCHITECTURES _number_of_arches)
    if(NOT _number_of_arches)
      # - Default
      if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i386")
        # building for 32bit
      else()
        message(STATUS "WARNING: LIB_SUFFIX ${LIB_SUFFIX} inappropriate for this build")
	set(LIB_SUFFIX "")
      endif()
    elseif(_number_of_arches GREATER 1)
      # - Universal
    else()
      # - Use what the user specified
      if (${CMAKE_OSX_ARCHITECTURES} STREQUAL "i386")
        # building for 32bit
      else()
        message(STATUS "WARNING: LIB_SUFFIX ${LIB_SUFFIX} inappropriate for this build")
	set(LIB_SUFFIX "")
      endif()
    endif()
  else()
    #message(STATUS "checking LIB_SUFFIX ${LIB_SUFFIX} against ${CMAKE_SYSTEM_PROCESSOR} ")
    if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
      # building for 32bit
    elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i386")
      # building for 32bit
    else()
      message(STATUS "WARNING: LIB_SUFFIX ${LIB_SUFFIX} inappropriate for this build")
      set(LIB_SUFFIX "")
    endif()
  endif()
endmacro( _clhep_lib_suffix_32 )

macro( clhep_lib_suffix )
  if(LIB_SUFFIX)
    if ( ${LIB_SUFFIX} STREQUAL "64" )
      _clhep_lib_suffix_64()
    elseif( ${LIB_SUFFIX} STREQUAL "32" )
      _clhep_lib_suffix_32()
    endif()
  endif()
  message(STATUS "libraries will be installed in $ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}")
endmacro( clhep_lib_suffix )

macro( clhep_enable_asserts )
  string(REGEX REPLACE "-DNDEBUG" " " CXXFLAGS "${CXXFLAGS}" )
  string(TOUPPER ${CMAKE_BUILD_TYPE} BTYPE_UC )
  string(REGEX REPLACE "-DNDEBUG" " " CMAKE_CXX_FLAGS_${BTYPE_UC} "${CMAKE_CXX_FLAGS_${BTYPE_UC}}" )
endmacro( clhep_enable_asserts )
