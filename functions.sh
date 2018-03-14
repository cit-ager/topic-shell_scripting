#!/bin/bash

### Functions

# Define Function
sample_function() {
    echo Hai from Function 
    echo Bye from Function 
    return 1 
}


## Main Program
sample_function
echo Exit status of Function = $?