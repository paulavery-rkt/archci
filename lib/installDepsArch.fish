function installDepsArch
	if test -f "$ARCHBUILD"
		pacman --asdeps --noconfirm -r $BUILDDIR/rootfs -S (cat $ARCHBUILD)
	end
end
