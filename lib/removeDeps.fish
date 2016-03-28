function removeDeps
	if not test -z (pacman -Qtdr $BUILDDIR/rootfs)
		pacman --noconfirm -r $BUILDDIR/rootfs -Rns (pacman -Qtdr $BUILDDIR/rootfs)
	end
end
