#!/bin/bash

## Total three quotes
# 1. Single Quote
# 2. Double Quote
# 3. Back Quote

## Single quotes will not consider any special characters.
a=10

echo '*'
echo '$a'

## Double quotes will consider only Dollar and Back quote as special characters 
echo "$a"
echo "Today date is $(date +%F)"
echo "Today date is `date +%F`"