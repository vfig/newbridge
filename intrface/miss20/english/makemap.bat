@echo off

rem cleaning up
echo "Cleaning up files"
del p00?ra.bin
del p00?r00?.pcx

rem constructing map
echo "Constructing map region file"
makerect p001ra.pcx
makerect p002ra.pcx p002rb.pcx
makerect p003ra.pcx

rem cutting out regions
echo "Cutting out map decals"
cutout p001ra.pcx
cutout p002ra.pcx p002rb.pcx
cutout p003ra.pcx
