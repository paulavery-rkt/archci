function runPostScript
	if test -f "$POSTSCRIPT"
		. $POSTSCRIPT $BUILDDIR/rootfs
		and set -g POSTRUN true
	end
end
