function runPreScript
	if test -f "$PRESCRIPT"
		. $PRESCRIPT $BUILDDIR/rootfs
		and set -g PRERUN true
	end
end
