#!/bin/sh

echo "What is the name of your project?"
read projectName

testProjectName=test_$projectName
testProjectMainCpp="$testProjectName"_main.cpp

echo "Where do you want it to live?"
read projectRoot

echo "What do you want the README to say?"
read readme

mkdir $projectRoot
cd $projectRoot

git init
git remote add origin https://OMGtechy@github.com/OMGtechy/"$projectRoot"
curl -u 'OMGtechy' https://api.github.com/user/repos -d "{\"name\":\""$projectRoot"\"}"

echo "*.swp
" > .gitignore

echo "$readme

[![Build Status](https://travis-ci.org/OMGtechy/"$projectRoot".svg)](https://travis-ci.org/OMGtechy/"$projectRoot")
[![codecov](https://codecov.io/gh/OMGtechy/"$projectRoot"/branch/master/graph/badge.svg)](https://codecov.io/gh/OMGtechy/"$projectRoot")
" > README.md

git add .gitignore

echo "language: cpp 

compiler:
    - gcc

addons:
    apt:
        sources:
            - ubuntu-toolchain-r-test
            - george-edison55-precise-backports
        packages:
            - cmake
            - cmake-data
            - g++-5
            - gcc-5

before_script:
    - export CXX="g++-5" COMPILER="g++-5" CC="gcc-5"
    - cd ./test
    - mkdir ./build
    - cd ./build
    - cmake ../ 
    - make -j

script: ./$testProjectName

after_success:
    - cd CMakeFiles/$testProjectName.dir/source
    - gcov-5 ./*
    - bash <(curl -s https://codecov.io/bash) -X gcov
" > .travis.yml

git add .travis.yml

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

IF(NOT WIN32)
    TARGET_LINK_LIBRARIES(
        $testProjectName
        gcov asan
    )

    SET_PROPERTY(
        TARGET $testProjectName
        APPEND_STRING PROPERTY COMPILE_FLAGS
        \" -fsanitize=address --coverage\"
    )
ENDIF()
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

git commit -m "Initial commit"
git push -u origin master

