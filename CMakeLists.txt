cmake_minimum_required (VERSION 3.6)

project (CUDD)

include (CheckIncludeFile)
include (CheckSymbolExists)

include ("${PROJECT_SOURCE_DIR}/cmake/CheckRun.cmake")

set(NAME cudd)
set(EMAIL Fabio@Colorado.EDU)
set(VERSION 3.0.0)

set (INCLUDE_DDDMP FALSE CACHE BOOL "include dddmp in libcudd")
set (INCLUDE_OBJ FALSE CACHE BOOL "include object wrapper in libcudd")
set (USE_SYSTEM_QSORT FALSE CACHE BOOL "use system qsort instead of portable one")

FIND_PROGRAM (HAVE_DOXYGEN doxygen)
if (HAVE_DOXYGEN)
	set (top_srcdir ${PROJECT_SOURCE_DIR})
	set (PACKAGE_NAME ${NAME})
	set (PACKAGE_VERSION ${VERSION})
	configure_file (
		"${PROJECT_SOURCE_DIR}/Doxyfile.in"
		"${PROJECT_BINARY_DIR}/Doxyfile"
	)
else ()
	MESSAGE ("Doxygen not found - continuing without Doxygen support")
endif ()

FIND_PROGRAM (HAVE_PDFLATEX pdflatex)
FIND_PROGRAM (HAVE_MAKEINDEX makeindex)
if (HAVE_PDFLATEX AND HAVE_MAKEINDEX)
	set (top_srcdir ${PROJECT_SOURCE_DIR})
	configure_file (
		"${PROJECT_SOURCE_DIR}/doc/cudd.tex.in"
		"${PROJECT_BINARY_DIR}/doc/cudd.tex"
	)
else ()
	MESSAGE ("pdflatex or makeindex not found - unable to compile manual to PDF")
endif ()

CHECK_INCLUDE_FILE (assert.h HAVE_ASSERT_H)
CHECK_INCLUDE_FILE (inttypes.h HAVE_INTTYPES_H)
CHECK_INCLUDE_FILE (stdlib.h HAVE_STDLIB_H)
CHECK_INCLUDE_FILE (string.h HAVE_STRING_H)
CHECK_INCLUDE_FILE (sys/time.h HAVE_SYS_TIME_H)
CHECK_INCLUDE_FILE (sys/times.h HAVE_SYS_TIMES_H)
CHECK_INCLUDE_FILE (sys/resource.h HAVE_SYS_RESOURCE_H)
CHECK_INCLUDE_FILE (sys/wait.h HAVE_SYS_WAIT_H)
CHECK_INCLUDE_FILE (unistd.h HAVE_UNISTD_H)

CHECK_SYMBOL_EXISTS (pow math.h HAVE_POW)
CHECK_SYMBOL_EXISTS (powl math.h HAVE_POWL)
CHECK_SYMBOL_EXISTS (getrlimit sys/time.h;sys/resource.h HAVE_GETRLIMIT)
CHECK_SYMBOL_EXISTS (getrusage sys/time.h;sys/resource.h HAVE_GETRUSAGE)
CHECK_SYMBOL_EXISTS (sysconf unistd.h HAVE_SYSCONF)

include (CheckTypeSize)

CHECK_TYPE_SIZE ("int" SIZEOF_INT)
CHECK_TYPE_SIZE ("void *" SIZEOF_VOID_P)

# Check for a working implementation of IEEE 754 floating point
# Specifically, check for correct treatment of +Infinity
CHECK_RUN (
"#include <math.h>
main(void)
{
    if (HUGE_VAL != HUGE_VAL * 3 || HUGE_VAL != HUGE_VAL / 3) return 1;
    return 0;
}"
HAVE_IEEE_754 c)

CHECK_RUN (
"class Myclass { explicit operator bool() const { return true; } };
int main() {
  void *p = nullptr;
}"
HAVE_MODERN_CXX cpp
)

CHECK_RUN (
"#include <thread>
main(void) {
  std::thread([] {}).join();
}
"
HAVE_WORKING_THREAD c
)

configure_file (
  "${PROJECT_SOURCE_DIR}/config.h.in"
  "${PROJECT_BINARY_DIR}/config.h"
  )

include_directories("${PROJECT_BINARY_DIR}")

add_subdirectory (cudd)
add_subdirectory (util)
add_subdirectory (st)
add_subdirectory (mtr)
add_subdirectory (epd)
if (INCLUDE_DDDMP)
	add_subdirectory (dddmp)
endif ()
if (INCLUDE_OBJ)
	add_subdirectory (cplusplus)
endif ()

if (HAVE_DOXYGEN)
	add_custom_command(
		OUTPUT html/index.html
		MAIN_DEPENDENCY Doxyfile
		DEPENDS ${SOURCE} ${HEADERS}
		COMMAND doxygen ${PROJECT_BINARY_DIR}/Doxyfile
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        COMMENT "Generating API documentation with Doxygen"
	)
	add_custom_target(doxygen ALL DEPENDS html/index.html)
endif ()

if (HAVE_PDFLATEX AND HAVE_MAKEINDEX)
	add_custom_command(
		OUTPUT doc/cudd.pdf
		MAIN_DEPENDENCY doc/cudd.tex
		DEPENDS ${PROJECT_SOURCE_DIR}/doc/phase.pdf
		COMMAND pdflatex cudd
		COMMAND makeindex cudd
		COMMAND pdflatex cudd
		COMMAND pdflatex cudd
		WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/doc
		COMMENT "Generating user manual with LaTeX"
	)
	add_custom_target(latex ALL DEPENDS doc/cudd.pdf)
endif ()
	
add_library (cudd ${SOURCE})

target_include_directories (cudd 
	PRIVATE ${PROJECT_SOURCE_DIR}
	PRIVATE ${PROJECT_SOURCE_DIR}/cudd
	PRIVATE ${PROJECT_SOURCE_DIR}/util
	PRIVATE ${PROJECT_SOURCE_DIR}/st
	PRIVATE ${PROJECT_SOURCE_DIR}/mtr
	PRIVATE ${PROJECT_SOURCE_DIR}/epd
	)
if (INCLUDE_DDDMP)
	target_include_directories(cudd PRIVATE ${PROJECT_SOURCE_DIR}/dddmp)
endif ()
if (INCLUDE_OBJ)
	target_include_directories(cudd PRIVATE ${PROJECT_SOURCE_DIR}/cplusplus)
endif ()