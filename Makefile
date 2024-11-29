# 手动指定内核版本
KERNEL_VERSION := linux-6.1.114
cpimage:
	cp /home/fz/mem_virt/${KERNEL_VERSION}/arch/x86/boot/bzImage ./bzImage
initramfs:
	# 创建 /dev/kvm 设备节点
	mkdir -p ./initramfs_dir/dev
	sudo mknod ./initramfs_dir/dev/kvm c 10 232
	cd ./initramfs_dir && find . -print0 | cpio -ov --null --format=newc | gzip -9 > ../initramfs.img
run:
	/home/fz/qemu-debug/build/install_dir/usr/local/bin/qemu-system-x86_64\
    	-kernel bzImage\
    	-initrd initramfs.img\
    	-m 1G\
    	-nographic\
    	-append "earlyprintk=serial,ttyS0 console=ttyS0 nokaslr kvm_intel.dump_invalid_vmcs=1"\
    	-machine accel=kvm -enable-kvm\
    	-s\
    	-cpu host

clean:
    # 删除 cpimage 和 initramfs 产生的文件
	rm -f bzImage
	rm -f initramfs.img
	rm -rf ./initramfs_dir/lib
	rm -rf ./initramfs_dir/dev