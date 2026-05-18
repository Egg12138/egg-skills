---
name: linux-quickbuild
description: minimal linux distro building workflow in order to quickly reproduce issues or do some tests
invocation_policy: automatic
---

## workflow

0. ask user about the topic, kernel version, and other environment requirements
1. checks prerequisite
2. checkout kernel source to desired
3. setup the kconfigs, check features to be enabled
4. build the kernel
5. setup the rootfs and init files
> analyse the issue, if rootfs type matters, `AskUserQuestion` for which type of rootfs
6. boot the kernel by qemu-system

## kernel source

kernel source locat

## build tools

### for x64

默认gcc
busybox static @directory $HOME/utils/Busybox-static

### for arm64

CROSS_COMPILE=aarch64-linux-gnu-
busybox static @directory $HOME/utils/Busybox-static

### for other platforms

analyse the CROSS_COMPILE prefix;search in $PATH
if not found, just download SDK under  /tmp

### qemu

qemu-system-*

