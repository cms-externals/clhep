# Throw a fatal error if cmake is invoked from the source code directory tree
# clhep_ensure_out_of_source_build()
#

macro (clhep_ensure_out_of_source_build)
  get_filename_component(buildDirPath "${CMAKE_BINARY_DIR}" REALPATH BASE_DIR)
  get_filename_component(sourceDirPath "${CMAKE_SOURCE_DIR}" REALPATH BASE_DIR)
  string(FIND "${buildDirPath}" "${sourceDirPath}/" is_subdir_pos)
  if ((buildDirPath STREQUAL sourceDirPath)
      OR (is_subdir_pos EQUAL 0))
  message(FATAL_ERROR "
ERROR: In source builds of this project are not allowed.
A separate build directory outside of `${CMAKE_SOURCE_DIR}' is required.
Please create one and run cmake from the build directory.
Also note that cmake has just added files to your source code directory.
We suggest getting a new copy of the source code.
Otherwise, delete `CMakeCache.txt' and the directory `CMakeFiles'.
  ")
  endif ()

endmacro ()
