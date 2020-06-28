# Partition Disk

If you are dual booting use Windows to resize your existing NTFS partition.
You'll need to allow enoug space for the following paritions:

* 200MB EFI (Should already be present)
* 2GB Boot
* >18GB Root
* >10GB Home
* >4GB SWAP space (2x the amount of installed RAM upto a max of 8GB)

So you need at least 35GB of free unallocated space on your drive.  The more
space you have the more you can allocate to either your root parition or your
home parition.

Boot in to (K)Ubuntu.  When it asks if you should `Try (K)Ubuntu` or `Install 
(K)Ubuntu` select Try.  This is important as we need to setup the partitions and
encryption before we start the installation process.

First step is to start the partition manager.  If you are using Kubuntu you can find
the KDE Partition Manager in the Application Menu.  On Ubuntu you should find GParted
installed.  Both offer very similar functionality.  Start the partition manager.
You'll see your unallocated space.  Right click on the unallocated space and select
new.  Make sure to select unformated from the dropdown menu and then press ok.  Now
click apply from the toolbar.  This turns the unallocated space in to unformated 
partition.  You can now address the partition so make a note of the partitions name
(e.g. /dev/nvme0n1p6, /dev/sda2, etc...)

Now to fire up the terminal and get our hands dirty turning that unallocated space in
to an encrypted set of partitions for Linux.  In KDE/Plasma/Kubuntu the terminal is
called Konsole though just typing "Terminal" in the application menu should be enough
to point you in the right direction.

First off we want to be a root.  We don't want to have to pre-fix every command we need
with sudo.  So first off type:

```
sudo su
```

Now you're root you want to turn your unallocated space in to a LUKS formated partition.
During this process you'll be asked for a password.  Remember this password or you'll be
unable to access your new setup once your done.

1. Format the partition using cryptsetup to LUKS. 

```
# cryptsetup luksFormat --type luks1 <partition>
```

e.g.

```
# cryptsetup luksFormat --type luks1 /dev/nvme0n1p6

WARNING!
========
This will overwrite data on /dev/nvme0n1p6 irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase for /dev/nvme0n1p6:
Verify passphrase:
```

2. Open the parition so we can start to work with it.
```
# cryptsetup open --type luks <partition> <name>
```

e.g.

```
# cryptsetup open --type luks /dev/nvme0n1p6 blade_crypt
Enter passphrase for /dev/nvme0n1p6:
```

3. Now we create a Linux virtual volume group using LVM.

```
# vgcreate <name> /dev/mapper/<name of decrypted drive>
```

e.g. 

```
# vgcreate bladevg /dev/mapper/blade_crypt
  Physical volume "/dev/mapper/blade_crypt" successfully created
  Volume group "bladevg" successfully created
```

4. Now we create the volumes we'll need for Linux.  We're going to create
4 volumes.  These are boot, root, home and swap.  Boot will be 2GB, swap
should 2x the amount of memory you have up to a maximum of 8GB, root should
be at least 20GB in size and finally you should allocate 75% of the rest to
your home directories.  Keep the remaining 25% free in case you need to add
some later to your HOME or ROOT partitions.

```
# lvcreate -n root -L20G <vg_name>
# lvcreate -n boot -L2G <vg_name>
# lvcreate -n swap -L8G <vg_name>
# lvcreate -n home -l75%FREE <vg_name>
```

e.g.

```
# lvcreate -n root -L20G bladevg
  Logical volume "root" created.
# lvcreate -n boot -L2G bladevg
  Logical volume "boot" created
# lvcreate -n swap -L8G bladevg
  Logical volume "swap" created
# lvcreate -n home -l75%FREE bladevg
  Logical volume "home" created
```

Finally you need to type the following on the commandline without hitting
enter.  You'll need to hit enter about half way through the (K)Ubuntu installer
process.

```
# echo "GRUB_ENABLE_CRYPTODISK=y" >> /target/etc/default/grub
```
**DO NOT HIT ENTER!**

Now start the (K)Ubuntu instller.  You'll find a link to this on the desktop.
The only parts of this to watch are when you come to deal with the disk setup.
You must make sure you select manual here and then click "> Continue".

Things to watch on this screen is you need to match the your newly created
logical volumes to the matching Linux partitions.  The other thing is that the
new logical volumes are the second listing for each volume.

Hit the install now button.  You'll be presented with a dialog box asking you
to confirm the changes.  Make sure they look similar to the ones in the screen
shot and then hit "Continue". Follow through the install process once you've
entered your user information, password and hostname hit continue.  As soon as
you hit continue you need to switch back to the terminal and hit enter on the
command you typed earlier.  This prevents the (K)Ubuntu installer from crashing
when the grub install happens.  Now let installer finishe installing as normal.
When the installer does finish make sure you hit the "Continue Testing" button.
You have a number of post install tasks to do now to have a working system.

First we need to set things up for chroot environment by remount the logical
volumes we created earlier.

```
# mount /dev/<volume-group>/root /target
# mount /dev/<volume-group>/boot /target/boot
# mount /dev/<volume-group>/home /target/home
# for n in proc sys dev etc/resolv.conf; do mount --rbind /$n /target/$n; done
```

e.g.
```
# mount /dev/bladevg/root /target
# mount /dev/bladevg/boot /target/boot
# mount /dev/bladevg/home /target/home
for n in proc sys dev etc/resolv.conf; do mount --rbind /$n /target/$n; done
``` 

Now chroot to target.  Now you can work on the new install and get everything
setup and running.

```
# chroot /target
```

First we need the UUID of the encrypted drive.  So use blkid to find this and
grep to narrow down the output.  You can narrow down by disk or by looking for
by looking for `crypto_LUKS`.  From here grab the UUID and make a note of it. 
Or copy it to your clipboard. You're going to need this quite a bit.

```
# blkid | grep /dev/<disk>
```

or 

```
# blkid | grep crypto_LUKS
```

e.g. 

```
# blkid | grep "/dev/nvme0n1"
/dev/nvme0n1p1: LABEL="Recovery" UUID="9A827D50827D31BD" TYPE="ntfs" PARTLABEL="Ba" PARTUUID="a031eef3-debc-4bc9-be1f-50e8c5840831"
/dev/nvme0n1p2: LABEL="SYSTEM" UUID="5C7F-2C0D" TYPE="vfat" PARTLABEL="EF" PARTUUID="eb64264f-8e85-48c0-8fe9-3fe636190cb0"
/dev/nvme0n1p4: LABEL="Blade 15" UUID="2A92408792405989" TYPE="ntfs" PARTLABEL="Ba" PARTUUID="a88e095c-0d80-4f1b-9b95-a648f093c522"
/dev/nvme0n1p5: LABEL="SHARED" UUID="DCA1-DEB1" TYPE="exfat" PARTLABEL="Basic data partition" PARTUUID="919236ee-14e7-47f2-b4d0-5be9d7ffc62d"
/dev/nvme0n1p6: LABEL="Linux Boot" UUID="f21f3962-0029-4aa7-89ba-769d6980e31f" TYPE="ext4" PARTUUID="100271b8-dec3-8448-ab9d-cd4748765cef"
/dev/nvme0n1p7: UUID="1901aaef-c771-454b-9c24-8324886b9f49" TYPE="crypto_LUKS" PARTUUID="ebc601e0-4677-5748-b4bc-d99a44c1cdb4"
/dev/nvme0n1p8: LABEL="Winre" UUID="E84A80364A800412" TYPE="ntfs" PARTUUID="61652c16-f61c-4917-97d5-6fe51c8559e2"
/dev/nvme0n1p3: PARTLABEL="Mi" PARTUUID="4afb38fb-0c0d-4a46-bead-bf863606b4d1"
```

or

```
# blkid | grep crypto_LUKS
/dev/nvme0n1p7: UUID="1901aaef-c771-454b-9c24-8324886b9f49" TYPE="crypto_LUKS" PARTUUID="ebc601e0-4677-5748-b4bc-d99a44c1cdb4"
```

Now we need to edit the default grub config

```
# vi /etc/default/grub
```

Now append to the `GRUB_CMDLINE_LINUX_DEFAULT` line `cryptdevice=UUID=<the UUID you grab in the previous step>`
e.g.
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash cryptdevice=UUID=f21f3962-0029-4aa7-89ba-769d6980e31f"
```

Underneith `GRUB_CMDLINE_LINUX=""` add `GRUB_ENABLE_CRYTODISK=y` and remove it from the bottom of the file.  This
keeps the all the gub options together and makes for a nicer config file.

Now save the changes.

Now we need to create a keyfile.

```
# dd if=/dev/urandom of=/boot/<partition-name>.keyfile bs=4096 count=1
```

e.g.
```
# dd if=/dev/urandom of=/boot/nvme0nG1p6.keyfile bs=4096 count=1
1+0 record in
1+0 record out
8192 bytes (8.2 kb, 8.0 KiB) copied, 0.000116315 s, 70.4 MB/s
```

Now we want to secure the keyfile and add it as an accepted passphrase
for our encrypted drive

```
# chmod u=r,go-rw /boot/<partition-name>.keyfile
# cryptsetup luksAddKey /dev/<partition> /boot/<partition-name>.keyfile
```

e.g.

```
# chmod u=r,go-rw /boot/nvme0n1p6.keyfile
# cryptsetup luksAddKey /dev/nvme0n1p6 /boot/nvme0n1p6.keyfile
WARNING: Locking directory /run/cryptsetup is missing!
Enter any existing passphrase:
```

We have to tell cryptsetup and initramfs where our keyfile is
and what it is looking for.

```
echo "KEYFILE_PATTERN=/boot/*.keyfile" >> /etc/cryptsetup-initramfs/conf-hook
echo "UMASK=0077" >> /etc/initramfs-tools/initramfs.conf
```

Now we setup the crypttab with the appropriate information

```
# echo "<crypt_name> UUID=<UUID copied earlier> /boot/<partition-name>.keyfile luks,discard" > /etc/crypttab
```

e.g.

```
# echo "blade_crypt UUID=39b5a2ac-470b-4833-a0be-c7e5306edfe4 /boot/nvme0n1p6.keyfile luks,discard" > /etc/crypttab
```

Finally update the initramfs

```
# update-initramfs -k all -c
```

e.g.

```
# update-initramfs -k all -c
update-initramfs: Generating /boot/initrd.img-5.4.0-26-generic
cryptsetup: WARNING: Skipping root target blade_crypt: uses a key file
update-initramfs: Generating /boot/initrd.img-5.4.0-39-generic
cryptsetup: WARNING: Skipping root target blade_crypt: uses a key file
```

Now you should be able to restart and everything should be stored encrypted on your device.

# VirtualBox EFI

There is a long standing but in VirtualBox which prevents it from starting
up from the installed OS so you may need to do the following to get the system
to boot properly:

```
sudo mount /dev/sda1 /boot/efi
echo '\EFI\ubuntu\grubx64.efi' > /boot/efi/startup.nsh
```
