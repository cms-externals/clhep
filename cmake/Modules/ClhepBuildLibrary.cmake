# Build package libraries.
# Build the main CLHEP source code list as we go.
#
# Recommended use:
# clhep_build_library( <package> <source code files> )
# 

macro(clhep_build_library package)
  set( CLHEP_${package}_SOURCES ${ARGN} )

  # build up the source list for CLHEP
  set( CLHEP_${package}_list CACHE INTERNAL "${package} sources" FORCE )
  foreach( file ${ARGN} )
    set( CLHEP_${package}_list 
         ${CLHEP_${package}_list} ${CMAKE_CURRENT_SOURCE_DIR}/${file}
         CACHE INTERNAL "${package} sources" 
	 )
  endforeach()
  ##message( STATUS "in ${package}, clheplib source list ${CLHEP_${package}_list}" )

  # check for dependencies
  set( package_library_list )
  set(package_library_listS)
  if( ${PACKAGE}_DEPS )
     foreach ( dep ${${PACKAGE}_DEPS} )
        ##message( STATUS "clhep_build_library ${package} will use ${dep}")
	list(APPEND package_library_list ${dep})
	list(APPEND package_library_listS ${dep}S)
     endforeach()
  endif()

  function(make_library package suffix type)
    ADD_LIBRARY(${package}${suffix} ${type} ${CLHEP_${package}_SOURCES})
    SET_TARGET_PROPERTIES(${package}${suffix}
      PROPERTIES 
        OUTPUT_NAME CLHEP-${package}-${VERSION}
    )
    # Do not add -Dname_EXPORTS to the command-line when building files in this
    # target. Doing so is actively harmful for the modules build because it
    # creates extra module variants, and not useful because we don't use these
    # macros.
    SET_TARGET_PROPERTIES(${package}${suffix} PROPERTIES DEFINE_SYMBOL "")
    target_link_libraries(${package}${suffix} ${package_library_list${suffix}} )

  endfunction()

  # Add the libraries and set properties
  make_library(${package} "" SHARED)
  if (CLHEP_BUILD_STATIC_LIBS)
    make_library(${package} "S" STATIC)
  endif()

  set(CLHEP_library_targets)
  list(APPEND CLHEP_library_targets ${package})
  if (CLHEP_BUILD_STATIC_LIBS)
    list(APPEND CLHEP_library_targets ${package}S)
  endif()

  # Install the libraries
  INSTALL (TARGETS ${CLHEP_library_targets}
    EXPORT CLHEPLibraryDepends
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib${LIB_SUFFIX}
    ARCHIVE DESTINATION lib${LIB_SUFFIX}
    INCLUDES DESTINATION include
  ) 


endmacro(clhep_build_library)

macro(clhep_build_libclhep )
  foreach( pkg ${ARGN} )
     ##message( STATUS "${pkg} sources are ${CLHEP_${pkg}_list}" )
     list(APPEND CLHEP_DEPS ${LIBRARY_OUTPUT_PATH}/${CMAKE_STATIC_LIBRARY_PREFIX}CLHEP-${pkg}-${VERSION}${CMAKE_STATIC_LIBRARY_SUFFIX} )
     list(APPEND clhep_sources ${CLHEP_${pkg}_list} )
  endforeach()
  ##message( STATUS "clheplib source list ${clhep_sources}" )

  function(make_clhep suffix type )
    ADD_LIBRARY (CLHEP${suffix} ${type} ${clhep_sources})

    SET_TARGET_PROPERTIES(CLHEP${suffix}
      PROPERTIES 
        OUTPUT_NAME CLHEP-${VERSION}
    )

    # Do not add -Dname_EXPORTS to the command-line when building files in this
    # target. Doing so is actively harmful for the modules build because it
    # creates extra module variants, and not useful because we don't use these
    # macros.
    SET_TARGET_PROPERTIES(CLHEP${suffix} PROPERTIES DEFINE_SYMBOL "")

  endfunction()

  make_clhep("" SHARED)
  if (CLHEP_BUILD_STATIC_LIBS)
    make_clhep("S" STATIC)
  endif()

  set(CLHEP_targets)
  list(APPEND CLHEP_targets CLHEP)
  if (CLHEP_BUILD_STATIC_LIBS)
    list(APPEND CLHEP_targets CLHEPS)
  endif()

  # export creates library dependency files for CLHEPConfig.cmake
  INSTALL(TARGETS ${CLHEP_targets}
    EXPORT CLHEPLibraryDepends
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib${LIB_SUFFIX}
    ARCHIVE DESTINATION lib${LIB_SUFFIX}
    INCLUDES DESTINATION include
  ) 

  if( ${CMAKE_SYSTEM_NAME} MATCHES "Windows" )
      # copy
      if (CLHEP_BUILD_STATIC_LIBS)
      file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/clhep_static_symlink 
        	 "execute_process(COMMAND \"${CMAKE_COMMAND}\" -E copy ${CMAKE_STATIC_LIBRARY_PREFIX}CLHEP-${VERSION}${CMAKE_STATIC_LIBRARY_SUFFIX} ${CMAKE_STATIC_LIBRARY_PREFIX}CLHEP${CMAKE_STATIC_LIBRARY_SUFFIX} WORKING_DIRECTORY \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}\" )" )
      endif()
      file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/clhep_shared_symlink 
        	 "execute_process(COMMAND \"${CMAKE_COMMAND}\" -E copy ${CMAKE_SHARED_LIBRARY_PREFIX}CLHEP-${VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_SHARED_LIBRARY_PREFIX}CLHEP${CMAKE_SHARED_LIBRARY_SUFFIX} WORKING_DIRECTORY \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin\" )" )
  else()
      # create the symbolic links
      if (CLHEP_BUILD_STATIC_LIBS)
      file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/clhep_static_symlink 
        	 "execute_process(COMMAND \"${CMAKE_COMMAND}\" -E create_symlink ${CMAKE_STATIC_LIBRARY_PREFIX}CLHEP-${VERSION}${CMAKE_STATIC_LIBRARY_SUFFIX} ${CMAKE_STATIC_LIBRARY_PREFIX}CLHEP${CMAKE_STATIC_LIBRARY_SUFFIX} WORKING_DIRECTORY \"\$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}\" )" )
      endif()
      file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/clhep_shared_symlink 
        	 "execute_process(COMMAND \"${CMAKE_COMMAND}\" -E create_symlink ${CMAKE_SHARED_LIBRARY_PREFIX}CLHEP-${VERSION}${CMAKE_SHARED_LIBRARY_SUFFIX} ${CMAKE_SHARED_LIBRARY_PREFIX}CLHEP${CMAKE_SHARED_LIBRARY_SUFFIX} WORKING_DIRECTORY \"\$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}\" )" )
  endif()

  if (CLHEP_BUILD_STATIC_LIBS)
    INSTALL(SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/clhep_static_symlink )
  endif()
  INSTALL(SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/clhep_shared_symlink )

endmacro(clhep_build_libclhep )
