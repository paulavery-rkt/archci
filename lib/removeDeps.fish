function removeDeps
	if not test -z (pacman -Qtdqr $BUILDDIR/rootfs)
		pacman --noconfirm -r $BUILDDIR/rootfs -Rns (pacman -Qtdqr $BUILDDIR/rootfs)
	end
end
