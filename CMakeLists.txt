cmake_minimum_required(VERSION 3.0)

set(CMAKE_CXX_STANDARD 11)

string(TIMESTAMP BUILD_TIMESTAMP "%Y%m%d-%H%M%S" UTC)

find_program(GIT_EXEC git)
mark_as_advanced(GIT_EXEC ADVANCED)
function(git_commit_hash DIR OUT_VAL)
  if (GIT_EXEC)
    execute_process(
            COMMAND ${GIT_EXEC} log -1 --format=%h
            WORKING_DIRECTORY ${DIR}
            OUTPUT_VARIABLE OUTPUT
            OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(${OUT_VAL} ${OUTPUT} PARENT_SCOPE)
  else()
    set(${OUT_VAL} "" PARENT_SCOPE)
  endif()
endfunction()
git_commit_hash(${CMAKE_SOURCE_DIR} MANIFEST_GIT_COMMIT_HASH)

function (LIST_JOIN RESULT SEPARATOR)
  set(_RESULT "")
  set(_FIRST_ARG TRUE)
  foreach (ARG ${ARGN})
    if (_FIRST_ARG)
      set(_RESULT "${_RESULT}${ARG}")
      set(_FIRST_ARG FALSE)
    else()
      set(_RESULT "${_RESULT}${SEPARATOR}${ARG}")
    endif()
  endforeach()
  set(${RESULT} "${_RESULT}" PARENT_SCOPE)
endfunction()

option(VERBOSE_LOGGING "Enable verbose logging in the compiled modules" OFF)
if (VERBOSE_LOGGING)
  add_definitions(-DSIMPLEIPC_DEBUG_LOGGING -DDAEMON_UTILS_LOGGING -DMSA_LOG_NETWORK)
endif()

option(DEB_XENIAL_DEPENDENCIES "Use Ubuntu 16.04 dependency list" OFF)
set(QT_RPATH "" CACHE STRING "Sets the install rpath to set for qt-enabled targets")
mark_as_advanced(DEB_XENIAL_DEPENDENCIES QT_RPATH)

include(ext/json.cmake)

add_subdirectory(logger)
add_subdirectory(base64)
add_subdirectory(file-util)
add_subdirectory(arg-parser)
add_subdirectory(rapidxml)

add_subdirectory(simple-ipc)
add_subdirectory(daemon-utils/client)
add_subdirectory(daemon-utils/server)

option(ENABLE_MSA_DAEMON "Enables building the daemon" ON)
if (ENABLE_MSA_DAEMON)
  add_subdirectory(msa)
  add_subdirectory(msa-daemon)
endif()

add_subdirectory(msa-daemon-client)

option(MSA_UI_PATH_DEV "Enable development MSA paths. This should be disabled for a packaged build." ON)
set(MSA_UI_PATH .)
set(MSA_UI_DEV_PATH )

option(ENABLE_MSA_GTK_UI "Enables the Gtk-based UI" OFF)
if (ENABLE_MSA_GTK_UI)
  add_subdirectory(msa-ui-gtk)
  list(APPEND MSA_UI_DEV_PATH ../msa-ui-gtk)
endif()
option(ENABLE_MSA_QT_UI "Enables the Qt-based UI" OFF)
if (ENABLE_MSA_QT_UI)
  add_subdirectory(msa-ui-qt)
  list(APPEND MSA_UI_DEV_PATH ../msa-ui-qt)
endif()

if (MSA_UI_PATH_DEV)
  list(APPEND MSA_UI_PATH ${MSA_UI_DEV_PATH})
endif()
if (ENABLE_MSA_DAEMON)
  list_join(MSA_UI_PATH_STR ":" ${MSA_UI_PATH})
  message("MSA UI app path has been set to: ${MSA_UI_PATH_STR}")
  target_compile_definitions(msa-daemon PRIVATE -DMSA_UI_APP_PATH="${MSA_UI_PATH_STR}")
endif()
