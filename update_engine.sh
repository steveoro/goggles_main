#!/bin/bash

# Resynchronze and update to DB Engine's last version, ignoring the included test dump:
GIT_LFS_SKIP_SMUDGE=1 bundle update goggles_db

