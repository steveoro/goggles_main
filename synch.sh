#!/bin/bash

git pull
# Ignore the test dump included in goggles_db gem:
GIT_LFS_SKIP_SMUDGE=1 bundle install
