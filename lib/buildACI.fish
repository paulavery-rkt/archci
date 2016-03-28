function buildACI
	# Combine infos into ACI name
	set ACI "$TRGDIR/images/$MOS/$MARCH/$MNAME-$MVERSION.aci"
	mkdir -p (dirname "$ACI")

	# Build the aci
	and actool build $BUILDDIR $ACI

	# Generate Signature
	and chown -R $UNPRIVUSER $TRGDIR
	and runuser -u $UNPRIVUSER -- gpg --armor --output $ACI.asc --detach-sig $ACI
	and chown -R $USER $TRGDIR
end
