#!/bin/bash

# ====== Normal Variables
Name=AWS

echo Welcome to $Name Training
echo ${Name} Trainer : Raghu
echo ${Name} Timings : 6AM

## SOme times you need to define a certain type of variables
# 1. Environment Variables

VAL=10
export VAL 
## OR

export VAL=10 

## Accessng variables in a different way
TIME=6
echo Class Time: ${TIME}AM

## Most of the times you need a variable from run time
# Command Substution 
DATE=$(date +%F)
echo "Welcome, Today date is $DATE"

## Arithematic Substution
# Addition
a=$((1+2))
