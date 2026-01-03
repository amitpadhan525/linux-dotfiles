#!/bin/bash

read -p "commit : " commit
time=$(date +"%Y-%m-%d %H:%M:%S")
git add .
git commit -m "$commit - $time"
git push origin main