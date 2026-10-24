cmake_minimum_required(VERSION 3.21)

# SurvivalAccord.dll, the "legacy" build on CharmedBaryon's CommonLibSSE-NG (Skyrim SE 1.5.97, AE before 1.6.1170, VR). The current build (1.6.1170 and newer,
# including 1.7.x) is built by E:/WorkSpace/ng-build from ng.cmake. Same sources.
project(SurvivalAccord VERSION 1.0.1 LANGUAGES CXX)

find_package(CommonLibSSE CONFIG REQUIRED)

add_commonlibsse_plugin(${PROJECT_NAME} NAME "SurvivalAccord" AUTHOR "CageTV" SOURCES src/main.cpp)

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)
target_include_directories(${PROJECT_NAME} PRIVATE src)
target_precompile_headers(${PROJECT_NAME} PRIVATE src/PCH.h)
target_compile_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Release>:/Z7>)
target_link_options(${PROJECT_NAME} PRIVATE $<$<CONFIG:Release>:/DEBUG /OPT:REF /OPT:ICF>)
