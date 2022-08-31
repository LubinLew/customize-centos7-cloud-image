# customize centos7 cloud image

> Official CentOS Cloud images: https://cloud.centos.org/centos/7/images/


## ENV

```bash
yum install -y qemu-kvm qemu-kvm-tools libvirt virt-install libguestfs-tools

systemctl start  libvirtd
systemctl enable libvirtd
```

## Usage

All you have to do is configure the `config/customize_cmd_lines.txt` file.

> syntax: `man virt-sysprep` option `--commands-from-file`

### Image Format

| Format                                         | suffix  |
| ---------------------------------------------- | ------- |
| QCOW2(KVM, Xen)                                | qcow2   |
| raw                                            | raw     |
| VHD(Hyper-V)                                   | vpc     |
| VMDK(VMware)                                   | vmdk    |
| VDI(VirtualBox)                                | vdi     |
| [QED(KVM)](https://wiki.qemu.org/Features/QED) | ~~qed~~ |

> https://docs.openstack.org/image-guide/convert-images.html

