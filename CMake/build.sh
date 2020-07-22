#!/bin/bash
# cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_LINKER=lld -DUSE_CHECK_API=ON -DUSE_CLANG_FORMAT=ON ..


# https://blog.csdn.net/ypshowm/article/details/100040729
# https://blog.csdn.net/u013187057/article/details/103052275 https://hokein.github.io/clang-tools-tutorial/modernize-cpp.html
clang-tidy --checks="modernize-use-nullptr,modernize-deprecated-headers,modernize-loop-convert" \
    --warnings-as-errors="modernize-use-nullptr,modernize-deprecated-headers,modernize-loop-convert" \
    --header-filter='.*' \
    --system-headers  \
    --export-fixes=clang-tidy-fixes.yml \
    test.cc
