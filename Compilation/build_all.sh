#!/bin/bash

rm -rf out
mkdir out

rm -rf temp
mkdir temp

./build.sh -a arm64
./build.sh -a arm64e
./build.sh -a x86_64

cp -r out/arm64/include ./out
mkdir ./out/lib

for lib in $( ls out/arm64/lib/*a ); do
	file=$( basename "${lib}" )
	lipo -create -arch arm64 out/arm64/lib/${file} -arch arm64e out/arm64e/lib/${file} -arch x86_64 out/x86_64/lib/${file}  -output out/lib/${file}
done

