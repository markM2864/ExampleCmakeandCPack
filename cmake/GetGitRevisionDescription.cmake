# Returns a version string from Git
#
# Forces a re-configure on each git commit so that you can trust the values of
# the variables in your build system.
#
# Requires CMake 2.6 or newer (uses the 'function' command)
#
# Original Author:
# 2009-2010 Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
# http://academic.cleardefinition.com
# Iowa State University HCI Graduate Program/VRAC
#
# Copyright Iowa State University 2009-2010.
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)

IF(__get_git_revision_description)
  RETURN()
ENDIF()
SET(__get_git_revision_description YES)

# Must run the following at "include" time, not at function call time, to find
# the path to this module rather than the path to a calling list file
GET_FILENAME_COMPONENT(_gitdescmoddir ${CMAKE_CURRENT_LIST_FILE} PATH)

FUNCTION(get_git_head_revision _refspecvar _hashvar)
  SET(GIT_PARENT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
  SET(GIT_DIR "${GIT_PARENT_DIR}/.git")
  WHILE(NOT EXISTS "${GIT_DIR}") # .git dir not found, search parent directories
    SET(GIT_PREVIOUS_PARENT "${GIT_PARENT_DIR}")
    GET_FILENAME_COMPONENT(GIT_PARENT_DIR ${GIT_PARENT_DIR} PATH)
    IF(GIT_PARENT_DIR STREQUAL GIT_PREVIOUS_PARENT)
      # Reached root directory
      SET(${_refspecvar} "GITDIR-NOTFOUND" PARENT_SCOPE)
      SET(${_hashvar} "GITDIR-NOTFOUND" PARENT_SCOPE)
      RETURN()
    ENDIF()
    SET(GIT_DIR "${GIT_PARENT_DIR}/.git")
  ENDWHILE()
  # Check if this is a submodule
  IF(NOT IS_DIRECTORY ${GIT_DIR})
    FILE(READ ${GIT_DIR} submodule)
    STRING(REGEX REPLACE "gitdir: (.*)\n$" "\\1" GIT_DIR_RELATIVE ${submodule})
    GET_FILENAME_COMPONENT(SUBMODULE_DIR ${GIT_DIR} PATH)
    GET_FILENAME_COMPONENT(GIT_DIR ${SUBMODULE_DIR}/${GIT_DIR_RELATIVE} ABSOLUTE)
  ENDIF()
  SET(GIT_DATA "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/git-data")
  IF(NOT EXISTS "${GIT_DATA}")
    FILE(MAKE_DIRECTORY "${GIT_DATA}")
  ENDIF()

  IF(NOT EXISTS "${GIT_DIR}/HEAD")
    RETURN()
  ENDIF()
  SET(HEAD_FILE "${GIT_DATA}/HEAD")
  CONFIGURE_FILE("${GIT_DIR}/HEAD" "${HEAD_FILE}" COPYONLY)

  CONFIGURE_FILE("${_gitdescmoddir}/GetGitRevisionDescription.cmake.in"
    "${GIT_DATA}/grabRef.cmake"
    @ONLY)
  INCLUDE("${GIT_DATA}/grabRef.cmake")

  set(${_refspecvar} "${HEAD_REF}" PARENT_SCOPE)
  SET(${_hashvar} "${HEAD_HASH}" PARENT_SCOPE)
ENDFUNCTION()

function(git_describe _var)
  if (NOT GIT_FOUND)
    find_package(Git QUIET)
  endif()
  get_git_head_revision(refspec hash)
  if (NOT GIT_FOUND)
    set(${_var} "GIT-NOTFOUND" PARENT_SCOPE)
    return()
  endif()
  if (NOT hash)
    set(${_var} "HEAD-HASH-NOTFOUND" PARENT_SCOPE)
    return()
  endif()

  execute_process(COMMAND
    "${GIT_EXECUTABLE}"
    describe

    ${ARGN}
    WORKING_DIRECTORY
      "${CMAKE_CURRENT_SOURCE_DIR}"
    RESULT_VARIABLE
    res
    OUTPUT_VARIABLE
    out
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if (NOT res EQUAL 0)
    set(out "${out}-${res}-NOTFOUND")
  endif()

  set(${_var} "${out}" PARENT_SCOPE)
endfunction()

function(git_get_exact_tag _var)
  git_describe(out --exact-match ${ARGN})
  set(${_var} "${out}" PARENT_SCOPE)
endfunction()
