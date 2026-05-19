---
name: linux-setup
description: >
  快速搭建 Linux 内核编译 + QEMU 启动的最小环境，用于复现 issue、做功能测试或性能验证。
  Use this skill whenever the user asks to build a custom Linux kernel, set up a QEMU test environment,
  reproduce a kernel bug, test a kernel feature, or do any kernel development work that requires
  compiling the kernel and booting it. Also triggers on requests involving kconfig, kernel config,
  kernel build, busybox rootfs, or qemu boot for kernel testing.
invocation_policy: automatic
---

# linux-setup: 内核快速搭建工作流

帮助你在本地快速搭建从内核源码编译到 QEMU 启动的完整环境。核心思想是**最小化、可重复**——不引入复杂的构建系统，只依赖交叉工具链、busybox 和 QEMU 这三个核心组件。

## 工作节奏

不要在每一步自顾自地执行默认行为。每到一个关键步骤，先问用户：

> "用默认方式，还是你有自己的指定方式？"

确认后再执行。

## 前置信息搜集

动手之前，一次性问清以下问题（不要挤牙膏）：
- 要复现/验证什么问题或功能？
- 目标内核版本或 commit？
- 目标架构？（x86_64 / arm64 / 其他）
- rootfs 类型偏好？（默认 initramfs，还是 ext4 disk / nfs？）

## 工作流

### 0. 检查前置条件

确保以下工具可用，缺失的直接安装：
- `git`, `make` — 基础构建工具
- 内核编译依赖（flex, bison, bc, openssl-devel, elfutils 等）
- `qemu-system-*` — 架构对应的 QEMU

架构相关的交叉编译工具链如果缺失，通过包管理器安装。

### 1. 准备内核源码

默认路径 `{{KERNEL_SRC}}`。
- 目录不存在 → 问用户源码位置，按需 clone
- 目录已存在 → `git fetch` 并 checkout 目标版本

如果用户指定了新路径，结束时问是否写回 SKILL.md 作为默认值。

### 2. 配置 kconfig

先检查源码树当前 `.config`（如果存在）是否满足需求。
- 满足 → 直接使用，跳过配置步骤
- 不满足 → 再问用户：用默认 defconfig 然后微调，还是用户提供自己的 .config？

如果走默认 defconfig 路线：从 defconfig 起步，利用 `scripts/config` 只开启/关闭测试所需的最小配置集。

详细的 kconfig 操作参考 `references/kconfig.md`。

### 3. 编译内核

配置确认后，执行编译：
```
make -j$(nproc) [ARCH=<arch>] [CROSS_COMPILE=<prefix>-]
```

编译产物路径见 `references/qemu.md`。编译前问用户是否需要额外 make 参数。

### 4. 制作 rootfs

先问用户：**用默认的 initramfs 自动制作，还是用户指定 rootfs 方式？**

- 默认方式：用 busybox 静态编译生成最小 initramfs
- 用户指定：尊重用户提供的方式、脚本或参数

详细的 rootfs 制作参考见 `references/rootfs.md`。

### 5. QEMU 启动

先问用户：**用默认的 QEMU 参数启动，还是用户指定参数？**

- 默认方式：根据架构自动构造最小启动命令
- 用户指定：直接使用用户提供的 QEMU 参数

详细的 QEMU 参数参考见 `references/qemu.md`。

### 6. 验证与交互

内核启动后确认用户可以访问 shell。如果启动失败，根据错误信息调整配置或参数。

## 持久化

如果执行过程中用户指定了新的默认值（源码路径、rootfs 方式、QEMU 参数等），任务结束时用 `AskUserQuestion` 询问是否将变更写入 SKILL.md。
