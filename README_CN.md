# 定义 centos7 云镜像

## 环境搭建

安装KVM环境和工具

```bash
yum install -y qemu-kvm qemu-kvm-tools libvirt virt-install libguestfs-tools

systemctl start libvirtd
systemctl enable libvirtd
```

> 制作比较耗费性能, 配置低的机器会很慢


----

## 镜像相关

### 镜像下载

官方原生镜像中只有一个`centos`用户(没有密码), 所以直接启动镜像会无法登录, 可以使用下面命令设置一个 root 密码 

```bash
virt-customize -a CentOS-7-x86_64-GenericCloud-2009.qcow2 --root-password password:root
````

官方地址:

```bash
https://cloud.centos.org/centos/7/images/
```

### 镜像格式

多种镜像格式, qcow2、qed、raw、vdi、vhd、vmdk。格式可以使用 `qemu-img` 命令进行转换.

| 格式                                             | 后缀名     | 简介                                                                              | 特点                                                                                                                                                                                                                                            |
| ---------------------------------------------- | ------- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| QCOW2(KVM, Xen)                                | qcow2   | QCOW2是QEMU实现的一种虚拟机镜像格式，<br>是用一个文件的形式来表示一块固定大小的块设备磁盘                             | 支持更小的磁盘占用。<br>支持写时拷贝（CoW，Copy-On-Write），镜像文件只反映底层磁盘变化。<br>支持快照，可以包含多个历史快照。<br>支持压缩和加密，可以选择ZLIB压缩和AES加密。                                                                                                                                       |
| raw                                            | raw     | RAW格式是直接给云服务器进行读写的文件。<br>RAW不支持动态增长空间，<br>是镜像中I/O性能最好的一种格式。                     | 寻址简单，访问效率较高。<br>可以通过格式转换工具方便地转换为其他格式。<br>可以方便地被本地物理主机挂载，可以在不启动虚拟机的情况下和宿主机进行数据传输。                                                                                                                                                              |
| VHD(Hyper-V)                                   | vpc     | VHD是微软提供的一种虚拟磁盘文件格式。<br>VHD文件格式可以被压缩成单个文件存放到本地物理主机的文件系统上，<br>主要包括云服务器启动所需的文件系统。 | 维护简单。可以在不影响物理分区的前提下对它进行分区、格式化、压缩、删除等操作。<br> 轻松备份。备份时仅需要将创建的VHD文件进行备份，也可以用备份工具将VHD文件所在的整个物理分区进行备份。<br> 迁移方便。当有一个VHD文件需要在多台计算机上使用时，只要先将此VHD文件从当前计算机上分离，将其复制到目的计算机上，再做附加操作即可。<br>可直接用于系统部署。可以使用Imagex工具将已经捕获的映像释放到VHD虚拟磁盘，或通过WDS服务器部署系统到VHD虚拟磁盘。 |
| VMDK(VMware)                                   | vmdk    | VMware虚拟机的磁盘文件。<br>虚拟机的操作系统和所有文件都在这个文件中                                         | -                                                                                                                                                                                                                                             |
| VDI(VirtualBox)                                | vdi     | VirtualBox 虚拟机的磁盘文件。                                                            | -                                                                                                                                                                                                                                             |
| [QED(KVM)](https://wiki.qemu.org/Features/QED) | ~~qed~~ | 是对 qcow2 格式的改进<br>但是已经停止开发维护,不推荐使用                                              | -                                                                                                                                                                                                                                             |

> https://docs.openstack.org/image-guide/convert-images.html
> 
> https://help.aliyun.com/document_detail/200600.html
> 
> [云服务器 镜像-操作指南-文档中心-腾讯云](https://cloud.tencent.com/document/product/213/4938)

----

## 镜像制作

主要借助 `virt-sysprep` 命令进行制作。

常用选项

| 选项                                   | 说明                           |
|----------------------------------------|--------------------------------|
| -a `file`                              | 指定 镜像文件                  |
| --network                              | 需要使用网络(安装或升级软件包) |
| --chmod `PERMISSIONS:FILE`             | 修改文件权限                   |
| --commands-from-file `FILENAME`        | 定制命令来自文件               |
| --copy `SOURCE:DEST`                   | 镜像系统内的复制               |
| --copy-in `LOCALPATH:REMOTEDIR`        | 将宿主机的文件复制到镜像内     |
| --upload `FILE:DEST`                   | 将宿主机的文件复制到镜像内(保持所有者和权限信息) |
| --delete `PATH`                        | 删除镜像系统内的文件           |
| --edit `FILE:EXPR`                     | 编辑镜像系统内的文件           |
| --update                               | 相当于 `yum update`            |
| --install `PKG1,PGK2`                  | 安装软件包(逗号分隔)           |
| --uninstall `PKG1,PGK2`                | 卸载软件包(逗号分隔)           |
| --run `SCRIPT`                         | 运行指定(镜像内)的 shell 脚本或者程序  |
| --run-command `CMD ARGS`               | 运行指定(镜像内)的 shell 命令          |
| --script `SCRIPT`                      | 运行指定(宿主机)的 shell 脚本或者程序  |
| --scriptdir `SCRIPTDIR`                | 挂载点文件夹, 用于 `--script` 命令 |
| --timezone `TIMEZONE`                  | 设置时区, 例如 `"Europe/London"`|
| --ssh-inject `USER[:SELECTOR]`         | 注入(镜像内存在的)用户的SSH免密登录KEY |
