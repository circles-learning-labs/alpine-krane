#!/bin/bash
git config --global --add safe.directory /github/workspace
build_kube_config.sh
make deploy
