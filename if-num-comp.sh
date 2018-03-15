#!/bin/bash

NUM=$(who |wc -l)
if [ $NUM -gt 2 ]; then 
    echo "CRITICAL :: Number of sessions exeeding 2"
    exit 1
else
    echo "OK :: Number of sessions are less than 2"
    exit 0
fi
