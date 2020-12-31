#!/bin/bash

sensors | grep temp1 | awk '{print $2}' | cut -c 2- | rev | cut -c 4- | rev
