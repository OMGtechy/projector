#!/bin/sh

echo "What is the name of your project?"
read projectName

testProjectName=test_$projectName
testProjectMainCpp="$testProjectName"_main.cpp

echo "Where do you want it to live?"
read projectRoot

mkdir $projectRoot
cd $projectRoot

git init

echo "*.swp
" > .gitignore

git add .gitignore

mkdir include
mkdir test

cd test

mkdir dependencies
cd dependencies

git submodule add https://github.com/philsquared/Catch.git

cd ../

echo "CMAKE_MINIMUM_REQUIRED(VERSION 3.2)

PROJECT($testProjectName)

ADD_EXECUTABLE(
    $testProjectName
    source/$testProjectMainCpp
)

INCLUDE_DIRECTORIES(
    $testProjectName
    dependencies/Catch/single_include
    ../include
)

# Add C++14 support
TARGET_COMPILE_FEATURES(
    $testProjectName
    PRIVATE
    cxx_relaxed_constexpr
)

SET_PROPERTY(
    TARGET $testProjectName
    APPEND_STRING PROPERTY COMPILE_FLAGS
    \"-Wall -Werror\"
)
" > CMakeLists.txt

git add CMakeLists.txt

mkdir source
cd source

echo "#define CATCH_CONFIG_MAIN
#include <catch.hpp>
" > $testProjectMainCpp

git add $testProjectMainCpp

cd ../

echo "build
" > .gitignore

git add .gitignore

mkdir build
cd build

cmake ../ -DCMAKE_BUILD_TYPE=Debug
make

