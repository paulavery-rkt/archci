function installArch
	if test -f "$ARCH"
		pacman --noconfirm --asexplicit -r $BUILDDIR/rootfs -S (cat $ARCH)
	end
end
