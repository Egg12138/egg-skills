# QEMU 启动参数参考

## 通用结构

```bash
qemu-system-<arch> \
    -kernel <kernel-image> \
    -append "console=<console-device> <extra-args>" \
    -nographic \
    -m 512M \
    -smp $(nproc)
```

## 各架构参数

| 架构 | QEMU 命令 | 内核镜像路径 | console 设备 |
|------|-----------|-------------|-------------|
| x86_64 | `qemu-system-x86_64` | `arch/x86_64/boot/bzImage` | `ttyS0` |
| arm64 | `qemu-system-aarch64 -machine virt -cpu cortex-a57` | `arch/arm64/boot/Image` | `ttyAMA0` |
| arm | `qemu-system-arm -machine virt` | `arch/arm/boot/zImage` | `ttyAMA0` |
| riscv64 | `qemu-system-riscv64 -machine virt` | `arch/riscv/boot/Image` | `ttyS0` |

## rootfs 对应参数

| rootfs 类型 | QEMU 参数 |
|-------------|-----------|
| initramfs (cpio) | `-initrd initramfs.cpio.gz` |
| ext4 disk (virtio) | `-drive file=rootfs.ext4,format=raw,if=virtio -append "root=/dev/vda"` |
| nfs | `-netdev user,id=n0 -device virtio-net,netdev=n0 -append "root=/dev/nfs nfsroot=<server>:/path"` |

## 调试参数

- `-s` — GDB stub 监听 tcp:1234
- `-S` — 在第一条指令暂停，等待 GDB
- `-append "... earlyprintk initcall_debug loglevel=8"` — 更多启动日志
