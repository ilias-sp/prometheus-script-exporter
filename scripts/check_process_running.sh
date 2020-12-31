#!/bin/bash

if [[ $# -ne 1 ]]
then
  exit 1
else
  ps -ef | grep "${1}" | grep -v grep | grep -v `basename $0` | wc -l
fi
