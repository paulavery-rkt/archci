function extractLabels
	# Extract labels from manifest
	set -g MOS (sx -jxi $MANIFEST x.labels | sx -jxlf "x.name==='os'" | sx -jx x.value)
	and set -g MARCH (sx -jxi $MANIFEST x.labels | sx -jxlf "x.name==='arch'" | sx -jx x.value)
	and set -g MNAME (sx -jxi $MANIFEST 'x.name.split("/")[1]')
	and set -g MVERSION (sx -jxi $MANIFEST x.labels | sx -jxlf "x.name==='version'" | sx -jx x.value)
	and set -g MUSER (sx -jxi $MANIFEST x.app.user)
	and set -g MGROUP (sx -jxi $MANIFEST x.app.group)

	# If we have no version in the manifest and no installed packages, abort
	and if test -z "$MVERSION" -a ! -f "$ARCH" -a ! -f "$AUR"
		abort 'No version in manifest and no aur/arch packages!'
	end
end
