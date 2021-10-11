#!/bin/bash
# this file is used as a substitute for entering the build command manually

ver=$(cat Dockerfile | grep "^FROM" | cut -f2 -d':')

docker build -t tomhmoj/rstudio:${ver} .
