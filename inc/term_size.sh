#!/bin/bash

S=`stty -a | perl -nE 'say $1 if m!columns (\d+)!'`
echo "set linesize $S "