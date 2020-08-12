#!/bin/bash -e

# to speed up execution of lsof inside
ulimit -S -n 1024

exec "$@"
