#!/usr/bin/env bash

docker login
docker build -t programic/git-backup:latest .
docker push programic/git-backup:latest