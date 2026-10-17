# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Lawrence Livermore National Security, LLC
#
# Description:
#   CMake configuration to build and serve documentation.
#
# Author: Nathan Hanford
#
# Copyright (c) 2026 Lawrence Livermore National Security (LLNS), LLC.
# See LICENSE file for more details.

cmake_minimum_required(VERSION 3.21)

# ============================================================================
# Find required tools
# ============================================================================
find_program(SPHINX_EXECUTABLE
    NAMES sphinx-build
    DOC "Path to sphinx-build executable"
)

if(NOT SPHINX_EXECUTABLE)
    message(WARNING
        "sphinx-build not found. Documentation will not be built.\n"
        "Install with: pip install sphinx sphinx-rtd-theme"
    )
    return()
endif()

# Find Python for serving docs
find_package(Python3 COMPONENTS Interpreter)

# Get Sphinx version
execute_process(
    COMMAND ${SPHINX_EXECUTABLE} --version
    OUTPUT_VARIABLE SPHINX_VERSION_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "Found Sphinx: ${SPHINX_EXECUTABLE}")
message(STATUS "Sphinx version: ${SPHINX_VERSION_OUTPUT}")

# ============================================================================
# Configure paths
# ============================================================================
set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
set(SPHINX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/_build)
set(SPHINX_HTML_DIR ${SPHINX_BUILD}/html)
set(SPHINX_MAN_DIR ${SPHINX_BUILD}/man)
set(SPHINX_CACHE_DIR ${SPHINX_BUILD}/.doctrees)

# Sphinx options
set(SPHINX_OPTS "" CACHE STRING "Extra options to pass to sphinx-build")
set(SPHINX_WARNINGS_AS_ERRORS OFF CACHE BOOL "Treat Sphinx warnings as errors")

if(SPHINX_WARNINGS_AS_ERRORS)
    list(APPEND SPHINX_OPTS -W --keep-going)
endif()

# ============================================================================
# Custom target: Build HTML documentation (RTD style)
# ============================================================================
add_custom_target(html
    COMMAND ${SPHINX_EXECUTABLE}
        -b html
        -d ${SPHINX_CACHE_DIR}
        ${SPHINX_OPTS}
        ${SPHINX_SOURCE}
        ${SPHINX_HTML_DIR}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Building HTML documentation with Sphinx"
    VERBATIM
)

add_custom_command(
    TARGET html POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "HTML documentation built successfully:"
    COMMAND ${CMAKE_COMMAND} -E echo "  ${SPHINX_HTML_DIR}/index.html"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    VERBATIM
)

# ============================================================================
# Custom target: Build man pages
# ============================================================================
add_custom_target(man
    COMMAND ${SPHINX_EXECUTABLE}
        -b man
        -d ${SPHINX_CACHE_DIR}
        ${SPHINX_OPTS}
        ${SPHINX_SOURCE}
        ${SPHINX_MAN_DIR}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Building man pages with Sphinx"
    VERBATIM
)

add_custom_command(
    TARGET man POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Man pages built successfully:"
    COMMAND ${CMAKE_COMMAND} -E echo "  ${SPHINX_MAN_DIR}/"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    VERBATIM
)

# ============================================================================
# Custom target: Check links
# ============================================================================
add_custom_target(linkcheck
    COMMAND ${SPHINX_EXECUTABLE}
        -b linkcheck
        -d ${SPHINX_CACHE_DIR}
        ${SPHINX_OPTS}
        ${SPHINX_SOURCE}
        ${SPHINX_BUILD}/linkcheck
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Checking links in documentation"
    VERBATIM
)

# ============================================================================
# Custom target: Serve HTML documentation on localhost:8000
# ============================================================================
if(Python3_FOUND)
    add_custom_target(serve
        COMMAND ${CMAKE_COMMAND} -E echo "Starting web server at http://localhost:8000"
        COMMAND ${CMAKE_COMMAND} -E echo "Press Ctrl+C to stop"
        COMMAND ${CMAKE_COMMAND} -E echo ""
        COMMAND ${Python3_EXECUTABLE} -m http.server 8000
        WORKING_DIRECTORY ${SPHINX_HTML_DIR}
        DEPENDS html
        COMMENT "Serving HTML documentation on http://localhost:8000"
        VERBATIM
    )
endif()

# ============================================================================
# Custom target: Clean documentation build directory
# ============================================================================
add_custom_target(clean-docs
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${SPHINX_BUILD}
    COMMENT "Cleaning documentation build directory"
    VERBATIM
)

# ============================================================================
# Installation rules
# ============================================================================

install(
    DIRECTORY ${SPHINX_MAN_DIR}/
    DESTINATION share/man/man1
    COMPONENT man
    FILES_MATCHING PATTERN "*.1"
)

# Install HTML documentation
install(
    DIRECTORY ${SPHINX_HTML_DIR}/
    COMPONENT html
    DESTINATION share/doc/phloem/html
)

# ============================================================================
# Help target
# ============================================================================
add_custom_target(help-docs
    COMMAND ${CMAKE_COMMAND} -E echo "Available documentation targets:"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "  html        - Build HTML documentation (RTD style)"
    COMMAND ${CMAKE_COMMAND} -E echo "  man         - Build man pages"
    COMMAND ${CMAKE_COMMAND} -E echo "  linkcheck   - Check for broken links"
    COMMAND ${CMAKE_COMMAND} -E echo "  serve       - Serve HTML docs on http://localhost:8000"
    COMMAND ${CMAKE_COMMAND} -E echo "  clean-docs  - Clean documentation build directory"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Installation locations:"
    COMMAND ${CMAKE_COMMAND} -E echo "  Man pages:  \${CMAKE_INSTALL_PREFIX}/share/man1/"
    COMMAND ${CMAKE_COMMAND} -E echo "  HTML docs:  \${CMAKE_INSTALL_PREFIX}/share/doc/phloem/html/"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    VERBATIM
)

# ============================================================================
# Print configuration summary
# ============================================================================
message(STATUS "")
message(STATUS "=== Documentation Configuration ===")
message(STATUS "Sphinx executable: ${SPHINX_EXECUTABLE}")
message(STATUS "Source directory:  ${SPHINX_SOURCE}")
message(STATUS "Build directory:   ${SPHINX_BUILD}")
message(STATUS "")
message(STATUS "Build targets:")
message(STATUS "  - HTML (RTD style)")
message(STATUS "  - Man pages")
message(STATUS "")
message(STATUS "Installation:")
message(STATUS "  Man pages: \${CMAKE_INSTALL_PREFIX}/share/man1/")
message(STATUS "  HTML docs: \${CMAKE_INSTALL_PREFIX}/share/doc/phloem/html/")
message(STATUS "===================================")
message(STATUS "")
