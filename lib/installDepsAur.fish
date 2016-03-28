function installDepsAur
	if test -f "$AURBUILD"
		# Only make the packages with pacaur, then install them with pacman
		env PKGDEST=$AURBUILDDIR runuser -u $UNPRIVUSER -- pacaur --noconfirm --noedit --foreign -m (cat $AURBUILD)
		and pacman -r $BUILDDIR/rootfs --asdeps --noconfirm -U $AURBUILDDIR/*
	end
end
