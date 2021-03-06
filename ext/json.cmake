include(FetchContent)

FetchContent_Declare(
        nlohmann_json_ext
        URL "https://github.com/nlohmann/json/releases/download/v3.7.3/include.zip"
)

FetchContent_GetProperties(nlohmann_json_ext)
if(NOT nlohmann_json_ext_POPULATED)
  FetchContent_Populate(nlohmann_json_ext)
endif()

add_library(nlohmann_json INTERFACE IMPORTED)
add_dependencies(nlohmann_json nlohmann_json_ext)
set_property(TARGET nlohmann_json PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${nlohmann_json_ext_SOURCE_DIR}/include")