#!/bin/bash

ver=$(cat Dockerfile | grep "^FROM" | cut -f2 -d':')

docker build -t tomhmoj/rstudio:${ver} .
