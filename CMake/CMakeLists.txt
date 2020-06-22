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

    if(EXISTS "${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl")
        EXECUTE_PROCESS(COMMAND test -x ${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl
            RESULT_VARIABLE checkAPI_permission)
        IF(checkAPI_permission)
            MESSAGE(STATUS "No execute permissions on checkAPIs.pl, please add executale permission...")
            # file(COPY ${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl
            #     DESTINATION ${CMAKE_SOURCE_DIR}/tools
            #     #PERMISSIONS OWNER_EXECUTE GROUP_EXECUTE WORLD_EXECUTE OWNER_READ GROUP_READ WORLD_READ
            #     FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)
        ENDIF()
    else()
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
            DOWNLOAD_DIR        ${CMAKE_SOURCE_DIR}/tools
            # DOWNLOAD_NAME       jsoncpp_1.8.4.tar.gz
            )
        FetchContent_GetProperties(googletest)
        if(NOT wiresharkcheckapi_POPULATED)
            FetchContent_Populate(WireSharkCheckAPI)
            #FetchContent_MakeAvailable(WireSharkCheckAPI)
            #create gt build directory in binary tree
            #add_subdirectory(${googletest_SOURCE_DIR} gt)
        endif()

        # file (COPY sourcefile DESTINATION
        #     ${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl)
        file(COPY ${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl
            DESTINATION ${CMAKE_SOURCE_DIR}/tools/checkAPIs.pl
            FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)
    endif()

    include(UseCheckAPI)
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

add_executable(test ${ALL_SRCS})
add_dependencies(test checkAPI)
