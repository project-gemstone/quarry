#!/bin/bash

msg() {
	printf '[\033[32m INFO\033[m ] %s\n' "$@"
}

warn() {
    printf '[\033[33m WARN\033[m ] %s\n' "$@"
}

fail() {
	printf '[\033[31m FAIL\033[m ] %s\n' "$@"
	exit 1
}

if [ ! -n "$1" ]; then
  fail "Need to specify the directory for quarry repo..."
fi

if [ ! -d "$1" ]; then
  fail "Quarry repo does not exist..."
fi

if [ ! -n "$2" ]; then
  fail "Need to specify the directory for the root filesystem..."
fi

if [ ! -d "$2" ]; then
  fail "Root filesystem does not exist..."
fi

REPO=$1
ROOTFS=$2
