# https://root.cern.ch/how/integrate-root-my-project-cmake
# list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTSYS})
# list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTDIR})
# # find_program( ROOTCONFIG root-config)
# # if (EXISTS ${ROOTCONFIG})
#   # message(STATUS "Using root-config at ${ROOTCONFIG}")
#   # indep. if root built with cmake assume the root-cint is in the path
#   # execute_process ( COMMAND root-config --prefix WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_DIR OUTPUT_STRIP_TRAILING_WHITESPACE )
#   # #message ("[info] ROOT_DIR: ${ROOT_DIR}")
#   # execute_process ( COMMAND root-config --etcdir WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_ETCDIR OUTPUT_STRIP_TRAILING_WHITESPACE )
#   # set( CMAKE_MODULE_PATH "${ROOT_ETCDIR}/cmake" )
#   # execute_process ( COMMAND root-config --libs WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE )
#   # message ("[info] CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")
#   # if(DEFINED ROOT_USE_FILE) 
#   #   include(${ROOT_USE_FILE}) 
#   # else() 
#   #   include_directories(${ROOT_INCLUDE_DIRS}) 
#   # endif() 
# #endif()

# if (NOT $ENV{ROOTSYS})
#   find_program( ROOTCONFIG root-config )
#   if (${ROOTCONFIG})
#     execute_process ( COMMAND root-config --prefix WORKING_DIRECTORY /tmp OUTPUT_VARIABLE RC_ROOTSYS OUTPUT_STRIP_TRAILING_WHITESPACE )
#     set(ENV{ROOTSYS} ${RC_ROOTSYS})
#     message(STATUS "Setting \$ENV{ROOTSYS} to $ENV{ROOTSYS} based on ${ROOTCONFIG}")
#   endif(${ROOTCONFIG})
# endif(NOT $ENV{ROOTSYS})

if (NOT $ENV{ROOTSYS})
  list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTSYS})
endif(NOT $ENV{ROOTSYS})

find_program( ROOTCONFIG root-config HINTS $ENV{ROOTSYS}/bin)
if (NOT ROOTCONFIG)
  message(STATUS "Adding path to ${CMAKE_HEPPY_DIR}/external/root/root-current")
  list(APPEND CMAKE_PREFIX_PATH ${CMAKE_HEPPY_DIR}/external/root/root-current)
endif(NOT ROOTCONFIG)

# if ($ENV{ROOTSYS})
#   list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTSYS})
# endif($ENV{ROOTSYS})

find_package(ROOT 6.18)
if (ROOT_FOUND)
  message(STATUS "${Green}ROOT ver. ${ROOT_VERSION}${ColourReset}")
  if (${ROOT_VERSION} VERSION_GREATER "6.22")
    message(STATUS "processing for ROOT version ${ROOT_VERSION}")
    if(HEPPY_PYTHON_FOUND) # from common_heppy_finds.cmake
      message(STATUS "${Yellow}- note will look for ROOTPythonizations${Python_VERSION_MAJOR}_${Python_VERSION_MINOR}")
      find_package(ROOT 6.22 COMPONENTS RIO EG ROOTPythonizations${Python_VERSION_MAJOR}_${Python_VERSION_MINOR})
    else(HEPPY_PYTHON_FOUND)
        message(FATAL_ERROR "${Red}Python not found - common_heppy_finds.cmake failed already?${ColourReset}")
    endif(HEPPY_PYTHON_FOUND)

    include(${ROOT_USE_FILE}) 
    if (NOT ROOTCONFIG)
      find_program( ROOTCONFIG root-config HINTS $ENV{ROOTSYS}/bin)
    endif(NOT ROOTCONFIG)
    if (ROOTCONFIG)
      execute_process ( COMMAND ${ROOTCONFIG} --version WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE )
      execute_process ( COMMAND find ${ROOT_LIBRARY_DIR} -name "ROOTTPython.pcm" WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_PYTHON OUTPUT_STRIP_TRAILING_WHITESPACE )
      execute_process ( COMMAND ${ROOTCONFIG} --prefix WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_HEPPY_PREFIX OUTPUT_STRIP_TRAILING_WHITESPACE )
      if (ROOT_PYTHON)
        # message(STATUS "${Green}ROOT python module: ${ROOT_PYTHON}${ColourReset}")
        # message(STATUS "${Green}ROOT_LIBRARY_DIR: ${ROOT_LIBRARY_DIR}${ColourReset}")
        string(REPLACE "${ROOT_LIBRARY_DIR}/" "" FJPYSUBDIR_TMP "${ROOT_PYTHON}")
        string(REPLACE "/ROOTTPython.pcm" "" ROOT_PYTHON_SUBDIR ${ROOT_PYTHON})
        message(STATUS "${Green}ROOT python module subdir: ${ROOT_PYTHON_SUBDIR}${ColourReset}")
        find_package(Python 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
        #set($ENV{LD_LIBRARY_PATH} "$ENV{LD_LIBRARY_PATH}:${ROOT_HEPPY_PREFIX}/lib")
        #execute_process(  COMMAND ${Python3_EXECUTABLE} -c "import sys; sys.path.append('${ROOT_PYTHON_SUBDIR}'); import ROOT; ROOT.gROOT.SetBatch(True); print('[i] ROOT version from within python:',ROOT.gROOT.GetVersion());" 
        execute_process(  COMMAND ${CMAKE_HEPPY_DIR}/external/root/test_root.sh ${ROOT_LIBRARY_DIR} ${Python_EXECUTABLE}
                          WORKING_DIRECTORY /tmp 
                          RESULT_VARIABLE LOAD_ROOT_PYTHON_RESULT 
                          OUTPUT_VARIABLE LOAD_ROOT_PYTHON 
                          ERROR_VARIABLE LOAD_ROOT_PYTHON_ERROR 
                          OUTPUT_STRIP_TRAILING_WHITESPACE )
        if (LOAD_ROOT_PYTHON_ERROR)
          message(STATUS "${Red}Loading ROOT python module - result:[${LOAD_ROOT_PYTHON_RESULT}] - failure!${ColourReset}")
          message(SEND_ERROR " ${Red}Loading ROOT python module FAILED:\n ${LOAD_ROOT_PYTHON_ERROR}${ColourReset}")
        else(LOAD_ROOT_PYTHON_ERROR)
          message(STATUS "${Green}Loading ROOT python module - result:[${LOAD_ROOT_PYTHON_RESULT}] - success!${ColourReset}")
          message("${LOAD_ROOT_PYTHON}")
          message(STATUS "${Green}ROOT ver. ${ROOT_VERSION}${ColourReset}")
        endif(LOAD_ROOT_PYTHON_ERROR)      
      else(ROOT_PYTHON)
        message(SEND_ERROR " ${Red}ROOT python module missing or not functional. This will create trouble.${ColourReset}")
      endif(ROOT_PYTHON)
    else(ROOTCONFIG)    
        message(SEND_ERROR " ${Red}root-config not found.${ColourReset}")
    endif(ROOTCONFIG)    


  else(${ROOT_VERSION} VERSION_GREATER "6.22")
  message(STATUS "processing for ROOT version ${ROOT_VERSION}")
  find_package(ROOT 6.18 COMPONENTS RIO EG PyROOT)
    include(${ROOT_USE_FILE}) 
    if (NOT ROOTCONFIG)
      find_program( ROOTCONFIG root-config HINTS $ENV{ROOTSYS}/bin)
    endif(NOT ROOTCONFIG)
    if (ROOTCONFIG)
      execute_process ( COMMAND ${ROOTCONFIG} --version WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE )
      execute_process ( COMMAND find ${ROOT_LIBRARY_DIR} -name "ROOT.py" WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_PYTHON OUTPUT_STRIP_TRAILING_WHITESPACE )
      execute_process ( COMMAND ${ROOTCONFIG} --prefix WORKING_DIRECTORY /tmp OUTPUT_VARIABLE ROOT_HEPPY_PREFIX OUTPUT_STRIP_TRAILING_WHITESPACE )
      if (ROOT_PYTHON)
        # message(STATUS "${Green}ROOT python module: ${ROOT_PYTHON}${ColourReset}")
        # message(STATUS "${Green}ROOT_LIBRARY_DIR: ${ROOT_LIBRARY_DIR}${ColourReset}")
        string(REPLACE "${ROOT_LIBRARY_DIR}/" "" FJPYSUBDIR_TMP "${ROOT_PYTHON}")
        string(REPLACE "/ROOT.py" "" ROOT_PYTHON_SUBDIR ${ROOT_PYTHON})
        message(STATUS "${Green}ROOT python module subdir: ${ROOT_PYTHON_SUBDIR}${ColourReset}")
        find_package(Python 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
        #set($ENV{LD_LIBRARY_PATH} "$ENV{LD_LIBRARY_PATH}:${ROOT_HEPPY_PREFIX}/lib")
        #execute_process(  COMMAND ${Python3_EXECUTABLE} -c "import sys; sys.path.append('${ROOT_PYTHON_SUBDIR}'); import ROOT; ROOT.gROOT.SetBatch(True); print('[i] ROOT version from within python:',ROOT.gROOT.GetVersion());" 
        execute_process(  COMMAND ${CMAKE_HEPPY_DIR}/external/root/test_root.sh ${ROOT_LIBRARY_DIR} ${Python_EXECUTABLE}
                          WORKING_DIRECTORY /tmp 
                          RESULT_VARIABLE LOAD_ROOT_PYTHON_RESULT 
                          OUTPUT_VARIABLE LOAD_ROOT_PYTHON 
                          ERROR_VARIABLE LOAD_ROOT_PYTHON_ERROR 
                          OUTPUT_STRIP_TRAILING_WHITESPACE )
        if (LOAD_ROOT_PYTHON_ERROR)
          message(STATUS "${Red}Loading ROOT python module - result:[${LOAD_ROOT_PYTHON_RESULT}] - failure!${ColourReset}")
          message(SEND_ERROR " ${Red}Loading ROOT python module FAILED:\n ${LOAD_ROOT_PYTHON_ERROR}${ColourReset}")
        else(LOAD_ROOT_PYTHON_ERROR)
          message(STATUS "${Green}Loading ROOT python module - result:[${LOAD_ROOT_PYTHON_RESULT}] - success!${ColourReset}")
          message("${LOAD_ROOT_PYTHON}")
          message(STATUS "${Green}ROOT ver. ${ROOT_VERSION}${ColourReset}")
        endif(LOAD_ROOT_PYTHON_ERROR)      
      else(ROOT_PYTHON)
        message(SEND_ERROR " ${Red}ROOT python module missing or not functional. This will create trouble.${ColourReset}")
      endif(ROOT_PYTHON)
    else(ROOTCONFIG)    
        message(SEND_ERROR " ${Red}root-config not found.${ColourReset}")
    endif(ROOTCONFIG)    
  endif(${ROOT_VERSION} VERSION_GREATER "6.22")
else(ROOT_FOUND)
    message(STATUS "${Yellow}ROOT not found - root-config not in the path? - some of the tools in pyjetty will require ROOT.${ColourReset}")
endif(ROOT_FOUND)
