function copyRootFS
	if test -d "$ROOTFS"
		cp -rpf $ROOTFS $BUILDDIR
	end
end
