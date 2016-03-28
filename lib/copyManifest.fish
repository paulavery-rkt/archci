function copyManifest
	# Extract user and group ids from rootfs
	set NMUSER (cat $BUILDDIR/rootfs/etc/passwd | grep "^$MUSER:" | cut -d: -f3)
	set NMGROUP (cat $BUILDDIR/rootfs/etc/group | grep "^$MGROUP:" | cut -d: -f3)

	# If we have no version, load it from the first installed package
	if test -z "$MVERSION"
		if test -f "$AUR"
			set -g MVERSION (pacman -r $BUILDDIR/rootfs -Q (head -1 $AUR) | sed 's/[^ ]* //')
		else
			set -g MVERSION (pacman -r $BUILDDIR/rootfs -Q (head -1 $ARCH) | sed 's/[^ ]* //')
		end
	end

	# Copy and patch the manifest
	cp "$MANIFEST" "$BUILDDIR/manifest"

	if not test -z "$MVERSION"
		# Patch in the new version
		sx -jxpF $BUILDDIR/manifest "x.labels.push({'name':'version', 'value':'$MVERSION'}); x"
	end

	# Patch in the resolved or group if available
	sx -jxpF $BUILDDIR/manifest "x.app.user = '$NMUSER' || '$MUSER'; x"
	sx -jxpF $BUILDDIR/manifest "x.app.group = '$NMGROUP' || '$MGROUP'; x"
end
