#!/bin/bash

read -p 'Enter the course: ' course
if [ -z "$course" ]; then 
    echo "Input Missing, Try Again !!"
    exit 1
fi
#### Using Simple IF-Statements

if [ "$course" == devops ]; then 
    echo "Welcome to DevOps Training"
fi

if [ "$course" = aws ]; then 
    echo "Welcome to AWS Training"
fi 


#### If-ELse Statements

if [ "$course" = devops ]; then 
    echo "Welcome to DevOps Training"
else
    echo "Welcome to AWS Training"
fi 


#### Else-If Statements

if [ "$course" = devops ]; then 
    echo "Welcome to DevOps Training"
elif [ "$course" = aws ]; then 
    echo "Welcome to AWS Training"
else 
    echo "No such training"
fi 


