# buildkit.cmake — Build Go core as part of the native Linux/Windows build
#
# Include this from a plugin's CMakeLists.txt and call:
#   apply_buildkit()
#
# This adds a custom command that runs build_tool before the native target is linked.

# Resolve at include-time so CMAKE_CURRENT_LIST_DIR is this file's directory
get_filename_component(BUILDKIT_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)

function(apply_buildkit)
  if(WIN32)
    set(_launcher "${BUILDKIT_DIR}/run_build_tool.cmd")
  else()
    set(_launcher "${BUILDKIT_DIR}/run_build_tool.sh")
  endif()

  # Project root is one level up from CMAKE_SOURCE_DIR (the top-level CMakeLists.txt
  # lives in linux/ or windows/, so project root is the parent).
  get_filename_component(PROJECT_ROOT "${CMAKE_SOURCE_DIR}" DIRECTORY)

  # The output files the build_tool produces
  if(WIN32)
    set(_output "${PROJECT_ROOT}/libclash/windows/FlClashCore.exe")
    set(_platform_args "windows")
  else()
    set(_output "${PROJECT_ROOT}/libclash/linux/FlClashCore")
    set(_platform_args "linux")
  endif()
  set(_phony "${CMAKE_CURRENT_BINARY_DIR}/buildkit_phony")

  set(BUILDKIT_ENV
    "BUILDKIT_CONFIGURATION=$<CONFIG>"
    "PROJECT_DIR=${PROJECT_ROOT}"
  )

  add_custom_command(
    OUTPUT ${_output} "${_phony}"
    COMMAND ${CMAKE_COMMAND} -E env ${BUILDKIT_ENV}
    "${_launcher}" ${_platform_args}
    WORKING_DIRECTORY "${PROJECT_ROOT}"
    VERBATIM
  )

  # Match Cargokit's symbolic-output and ALL-target structure so the native
  # generator reevaluates this build rule on each build.
  set_source_files_properties("${_phony}" PROPERTIES SYMBOLIC TRUE)
  add_custom_target(setup_buildkit_build ALL DEPENDS ${_output})
endfunction()
