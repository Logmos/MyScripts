cmake_minimum_required(VERSION  3.12)
project(MyProject)
message(STATUS "Generating build using CMake ${CMAKE_VERSION}")

include(CMakeOptions.txt)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)

if(USE_CHECK_API)
    add_custom_target(checkAPI)
    set_target_properties(checkAPI
        PROPERTIES
        FOLDER "Auxiliary"
        EXCLUDE_FROM_ALL True
        EXCLUDE_FROM_DEFAULT_BUILD True
        )

    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/3rdparty/checkAPIs.pl")
        # include(ExternalProject)
        # ExternalProject_Add(
        #     WireSharkCheckAPI
        #     URL https://raw.githubusercontent.com/wireshark/wireshark/master/tools/checkAPIs.pl
        #     PREFIX WireSharTools
        #     DOWNLOAD_NO_EXTRACT ON
        #     LOG_DOWNLOAD ON
        #     LOG_CONFIGURE ON
        #     LOG_BUILD ON)
        include(FetchContent)
        set(FETCHCONTENT_QUIET OFF)
        # https://gitlab.kitware.com/cmake/cmake/-/issues/18103
        FetchContent_Declare(
            WireSharkCheckAPI
            URL https://raw.githubusercontent.com/wireshark/wireshark/master/tools/checkAPIs.pl
            DOWNLOAD_NO_EXTRACT TRUE
            DOWNLOAD_DIR        ${CMAKE_SOURCE_DIR}/3rdparty
            # DOWNLOAD_NAME     checkAPIs.pl
            )
        FetchContent_GetProperties(googletest)
        if(NOT wiresharkcheckapi_POPULATED)
            FetchContent_Populate(WireSharkCheckAPI)
            #FetchContent_MakeAvailable(WireSharkCheckAPI)
            #create gt build directory in binary tree
            #add_subdirectory(${googletest_SOURCE_DIR} gt)
        endif()
    endif()

    file(COPY ${CMAKE_SOURCE_DIR}/3rdparty/checkAPIs.pl
        DESTINATION ${CMAKE_SOURCE_DIR}/tools
        FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)
    file(SIZE ${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl FileSize)
    if (FileSize EQUAL 0)
        message(FATAL_ERROR "${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl is empty, maybe downloading failed!!!")
    endif()
    EXECUTE_PROCESS(COMMAND test -x ${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl
        RESULT_VARIABLE checkAPI_permission)
    # if(checkAPI_permission)
    #     MESSAGE(STATUS "No execute permissions on checkAPIs.pl, please add executale permission...")
    # endif()

    include(UseCheckAPI)
endif()

if(USE_CLANG_FORMAT)
    add_custom_target(clangFormat)
    set_target_properties(clangFormat
        PROPERTIES
        FOLDER "Auxiliary"
        EXCLUDE_FROM_ALL True
        EXCLUDE_FROM_DEFAULT_BUILD True
        )
    include(UseClangFormat)
endif()

#cmake已经集成clang-tidy
#https://ortogonal.github.io/cmake-clang-tidy/
#This is convenient enough
#set(CMAKE_CXX_CLANG_TIDY "clang-tidy;--checks=*;--warnings-as-errors=*")
if(USE_CLANG_TIDY)
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/build/compile_commands.json")
        unset(USE_CLANG_TIDY)
    else()
        add_custom_target(clangTidy)
        set_target_properties(clangTidy
            PROPERTIES
            FOLDER "Auxiliary"
            EXCLUDE_FROM_ALL True
            EXCLUDE_FROM_DEFAULT_BUILD True
            )
        include(UseClangTidy)
    endif()
endif()

set(ALL_SRCS test.cc)
if(USE_CHECK_API)
    CHECKAPI(
        NAME
        test
        SWITCHES
        --build
        SOURCES
        ${ALL_SRCS}
        )
endif()

if(USE_CLANG_FORMAT)
    CLANGFORMAT(
        NAME
        test
        SWITCHES
        -style=LLVM
        -i
        SOURCES
        ${ALL_SRCS}
        )
endif()

if(USE_CLANG_TIDY)
    CLANGTIDY(
        NAME
        test
        SWITCHES
        --checks="modernize-use-nullptr,modernize-deprecated-headers,modernize-loop-convert"
        --warnings-as-errors="modernize-use-nullptr,modernize-deprecated-headers,modernize-loop-convert"
        --header-filter='.*'
        #--system-headers
        --export-fixes=clang-tidy-fixes.yml
        #--fix
        SOURCES
        ${ALL_SRCS}
        )
endif()

add_executable(test ${ALL_SRCS})
if(USE_CHECK_API)
add_dependencies(test checkAPI)
endif()
if(USE_CLANG_FORMAT)
add_dependencies(test clangFormat)
endif()
if(USE_CLANG_TIDY)
add_dependencies(test clangTidy)
endif()
