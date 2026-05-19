# rootfs 制作参考

## 方式 A: initramfs (cpio) — 默认，最轻量

适合大部分内核功能测试。不需要磁盘设备，内核自带到内存。

```bash
# 准备目录结构
mkdir -p rootfs/{bin,sbin,etc,proc,sys,dev,usr/bin,usr/sbin}

# 复制静态编译的 busybox
cp {{BUSYBOX_PATH}} rootfs/bin/busybox

# 创建所有 busybox 工具的 symlink
for cmd in $(rootfs/bin/busybox --list); do
    ln -sf /bin/busybox rootfs/bin/$cmd
done

# init 脚本
cat > rootfs/init << 'INIT'
#!/bin/busybox sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t tmpfs none /tmp
echo "=== Booted ==="
exec /bin/sh
INIT
chmod +x rootfs/init

# 打包
cd rootfs && find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz
```

如果用户需要更复杂的 init（网络、模块加载等），按需扩展 init 内容。

## 方式 B: ext4 disk image

适合需要持久化存储或完整文件系统的测试。

```bash
dd if=/dev/zero of=rootfs.ext4 bs=1M count=64
mkfs.ext4 rootfs.ext4
mkdir -p mnt
sudo mount rootfs.ext4 mnt
# 按 initramfs 的方式填充 busybox，但 init 脚本改为 /sbin/init
sudo umount mnt
```

## 方式 C: nfs

适合频繁更换内核模块的场景，QEMU 通过网络挂载 rootfs。需要宿主机运行 NFS server，较复杂，只在用户明确要求时使用。
