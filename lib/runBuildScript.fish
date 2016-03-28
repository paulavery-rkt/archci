function runBuildScript
	if test -f "$BUILDSCRIPT"
		cp $BUILDSCRIPT $BUILDDIR/rootfs/build
		and chroot $BUILDDIR/rootfs /build
		and rm -rf $BUILDDIR/rootfs/build
	end
end
