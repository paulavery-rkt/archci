function bootstrapRootFS
	mkdir -pm 755 $BUILDDIR/rootfs
	and pacstrap -cdGM $BUILDDIR/rootfs filesystem
end
