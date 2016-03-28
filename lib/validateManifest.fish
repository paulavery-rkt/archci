function validateManifest
	test -f "$MANIFEST"
	and actool validate $MANIFEST
end
