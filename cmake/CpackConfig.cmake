if (UNIX)
  set(CPACK_GENERATOR "DEB")
  set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "Example")
  set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
  set(CPACK_DEBIAN_PACKAGE_VERSION "${VERSION}")
  set(CPACK_PACKAGE_FILE_NAME ${PROJECT_NAME}-${VERSION_SHORT}-${CPACK_DEBIAN_PACKAGE_ARCHITECTURE})
  # put the packages you need here in a list
  # set(CPACK_DEBIAN_PACKAGE_DEPENDS "package1, package2 ...")
  set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Your name Your.email@here.com")
  # set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA ${some script here})
else()
  set(CPACK_GENERATOR "NSIS")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Example")
  set(CPACK_PACKAGE_VENDOR "Myself")
  set(CPACK_PACKAGE_VERSION_MAJOR ${VERSION_MAJOR})
  set(CPACK_PACKAGE_VERSION_MINOR ${VERSION_MINOR})
  set(CPACK_PACKAGE_VERSION_PATCH ${VERSION_PATCH})
  set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL OFF)
  set(CPACK_NSIS_MODIFY_PATH ON)
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "ExamplePackage\\\\Example")
  set(CPACK_PACKAGE_EXECUTABLES "ExamplePackage; Example Package")
  set(CPACK_NSIS_DISPLAY_NAME "Example Package")
  include(CPackComponent)
  cpack_add_install_type(Full DISPLAY_NAME "Install All Components")
  cpack_add_component(binaries
    DISPLAY_NAME "Main executable"
    DESCRIPTION "Example"
    REQUIRED
    INSTALL_TYPES Full
  )
  set(CPACK_COMPONENTS_ALL binaries)
endif()

include(CPack)