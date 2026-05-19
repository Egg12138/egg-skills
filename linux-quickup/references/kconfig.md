# kconfig 操作参考

## 策略

先检查源码树中已有的 `.config`。如果存在并且满足需求，直接使用，不要重新生成。

不满足时，从架构的 defconfig 起步，用 `scripts/config` 做非交互式精确开启/关闭：

```bash
# 先用当前 .config（如果满足需求）
make olddefconfig              # 更新已有 .config 到当前内核版本

# 如果不存在或不满足需求，加载架构默认配置
make defconfig                 # x86_64
make ARCH=arm64 defconfig      # arm64

# 用 scripts/config 做非交互式修改（精确、可复现）
scripts/config --enable CONFIG_DEBUG_INFO
scripts/config --enable CONFIG_EXT4_FS
scripts/config --disable CONFIG_COMPAT
scripts/config --module CONFIG_BLK_DEV
scripts/config --set-str CONFIG_LOCALVERSION "-test"

# 修改后统一确认
make olddefconfig
```

## QEMU 串口：8250 UART 配置

使用 QEMU `-nographic` 时，内核通过模拟的 8250/16550 UART 输出 console。必须确保以下配置开启：

```bash
scripts/config --enable CONFIG_SERIAL_8250
scripts/config --enable CONFIG_SERIAL_8250_CONSOLE
```

arm64 virt machine 还需要：
```bash
scripts/config --enable CONFIG_SERIAL_8250_PCI   # 早期 virt 平台通过 PCI 挂载 UART
```

确保 `console=` 参数与驱动匹配（x86_64 用 `ttyS0`，arm64 virt 新平台用 `ttyAMA0`，老平台可能走 `ttyS0`）。

## 原则

- 先复用已有 `.config`，再考虑重新生成
- 只修改需求相关的配置项，最小化变更
- 用 `scripts/config` 而非 menuconfig（可复现、可追溯）
- rootfs 类型决定必须启用的配置（initramfs → `CONFIG_BLK_DEV_INITRD`；ext4 disk → `CONFIG_EXT4_FS` + `CONFIG_VIRTIO_BLK`）
- QEMU console 依赖 8250 UART 驱动，缺失则启动后看不到任何输出
- 保留最终 .config 方便 review
