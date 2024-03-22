# Not entirely important, but you will get warnings
# in vscode if your minimum version if old enough
cmake_minimum_required(VERSION 3.15.0)

set(CMAKE_BUILD)

# include the cmake modules in the cmake folder
# this variable is a list so you can append other
# paths to it
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

include(AddSources)
include(GetGitRevisionDescription)

git_describe(VERSION --tags --dirty=-d)
message(STATUS "The git version is ${VERSION}")

string(REGEX REPLACE "^([0-9]+)\\..*" "\\1" VERSION_MAJOR "${VERSION}")
string(REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1" VERSION_MINOR "${VERSION}")
string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" VERSION_PATCH "${VERSION}")
string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+(.*)" "\\1" VERSION_SHA1 "${VERSION}")
set(VERSION_SHORT "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")


configure_file(${CMAKE_SOURCE_DIR}/cmake/version.cpp.in
                ${CMAKE_SOURCE_DIR}/version.cpp)
set(VERSION_FILE "${CMAKE_CURRENT_BINARY_DIR}/version.cpp")

project(ExampleProject VERSION ${VERSION_SHORT})

add_subdirectory(src)

message(STATUS "Source files: ${SRCS}")

add_executable(${PROJECT_NAME} "${SRCS}" ${VERSION_FILE})

target_include_directories(${PROJECT_NAME} PRIVATE
  include
)

# Intended for packaging through msys2 on windows
# Depends on your particular build configuration
set(MSYS_BIN_DIR "C:/msys64/ucrt64/bin")

# Just set these to which ever dlls you need for your project
set(DLLS
  "${MSYS_BIN_DIR}/libgcc_s_seh-1.dll"
  "${MSYS_BIN_DIR}/libstdc++-6.dll"
  "${MSYS_BIN_DIR}/libwinpthread-1.dll"
)

if (CMAKE_BUILD_TYPE STREQUAL "Release")
  install(
    TARGETS ${PROJECT_NAME}
    DESTINATION .
    COMPONENT binaries
  )

  install(
    FILES
    ${DLLS}
    DESTINATION .
    COMPONENT binaries
  )

  include(CpackConfig)
endif()