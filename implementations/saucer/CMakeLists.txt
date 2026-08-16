cmake_minimum_required(VERSION 3.25)

project(saucer-hello-world LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CXX_FLAGS_RELEASE "-Os -DNDEBUG")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)

get_filename_component(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(SAUCER_SOURCE "${REPO_ROOT}/temp/saucer/src/saucer")

set(saucer_examples OFF CACHE BOOL "" FORCE)
set(saucer_tests OFF CACHE BOOL "" FORCE)
set(saucer_backend WebKit CACHE STRING "" FORCE)
set(saucer_serializer Glaze CACHE STRING "" FORCE)
set(saucer_static ON CACHE BOOL "" FORCE)
set(saucer_prefer_remote OFF CACHE BOOL "" FORCE)

add_subdirectory("${SAUCER_SOURCE}" "${CMAKE_BINARY_DIR}/saucer" EXCLUDE_FROM_ALL)

add_executable(hello-world MACOSX_BUNDLE main.cpp)

set_target_properties(hello-world PROPERTIES
  MACOSX_BUNDLE TRUE
  MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist"
  MACOSX_BUNDLE_BUNDLE_NAME "Hello World"
  MACOSX_BUNDLE_GUI_IDENTIFIER "com.webview-hello-world-compare.saucer"
  MACOSX_BUNDLE_BUNDLE_VERSION "1.0.0"
  MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0.0"
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN ON
)

target_link_libraries(hello-world PRIVATE saucer)

add_custom_command(
  TARGET hello-world
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:hello-world>/../Resources"
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${CMAKE_CURRENT_SOURCE_DIR}/index.html"
    "$<TARGET_FILE_DIR:hello-world>/../Resources/index.html"
  COMMENT "Copy index.html into app bundle Resources"
)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
  add_custom_command(
    TARGET hello-world
    POST_BUILD
    COMMAND strip -x "$<TARGET_FILE:hello-world>"
    COMMENT "Strip release binary"
  )
endif()
