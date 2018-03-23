title: Compact vbox disk
date: 2016-09-29
tags: [virtualbox]

---

Compact vbox disk
===

- run defrag in the guest (Windows)
- nullify free space:
  With Linux guest run this:
  ```shell
  sudo dd if=/dev/zero of=/bigemptyfile bs=4096k
  sudo rm -rf /bigemptyfile
  ```
  With Windows guest, download SysinternalsSuite and run this:
  ```powershell
  sdelete –z
  ```
<!-- more -->
- shutdown the guest VM

- now run VBoxManage's compact command
  ```shell
  VBoxManage.exe modifyhd thedisk.vdi --compact
  ```

