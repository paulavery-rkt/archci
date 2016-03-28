function installAur
	if test -f "$AUR"
		# Only make the packages with pacaur, then install them with pacman
		env "PKGDEST=$AURDIR" runuser -u $UNPRIVUSER -- pacaur --noconfirm --noedit --foreign -m (cat $AUR)
		and pacman -r $BUILDDIR/rootfs --asexplicit --noconfirm -U $AURDIR/*
	end
end
