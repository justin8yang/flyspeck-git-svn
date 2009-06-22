#!/bin/bash

cd GraphDat
for i in *.dat ; do 
  glpsol -m ../graph0.mod -d $i | tee ${i}.sol
done