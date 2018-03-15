#!/bin/bash

read -p 'Enter the course: ' course 

case $course in
    devops) echo "Welcome to DevOps training" ;;
    aws) echo "Welcome to AWS training" ;;
    *) echo "No such training. We give only DevOps & AWS" ;;
esac
