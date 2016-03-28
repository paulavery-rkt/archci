#!/usr/bin/env fish

# Exit immediately if a command is not found
function notfound --on-event fish_command_not_found
	abort 'Command Not Found'
end

# Load fish-n-chips library
set chipsPwd (dirname -- (realpath -- (status -f)))
source $chipsPwd/chips/chips.fish $argv; or exit $status

# Include the sx if we installed from aur
set PATH $chipsPwd/node_modules/.bin $PATH

# Load all our functions
for f in $chipsPwd/lib/*
	source $f
end

# Set up fish-n-chips
name        archci
version     1.6.1
author      Florian Albertz
copyright   2016

info        'Script to create AppContainer Images from Arch Linux packages (Repo or Aur)'
synopsis    'archci [OPTIONS] SRCDIR TRGDIR'
description 'Takes a source directory and according to the files living within, it creates an app container image. For full information on the format of the source directory, read the README.md/manpage'

argument    '-V | --version        Print version information'
argument    '-h | --help           Show help page'
argument    '-v | --verbose        Print more information'
argument    '-u | --user    [user] User to run pacaur/makepkg as'

arg -V printVersion; and exit
arg -h help internal; and exit

# Set and check directories
if not set -g SRCDIR (restArg 1)
	abort "Source Directory not provided"
else
	if not test -d $SRCDIR
		abort "Source Directory not found"
	else
		set SRCDIR (realpath -- $SRCDIR)
	end
end

if not set -g TRGDIR (restArg 2)
	abort "Target Directory not provided"
else
	if not test -d $TRGDIR
		abort "Target Directory not found"
	else
		set TRGDIR (realpath -- $TRGDIR)
	end
end

# Check user, we cannot run if we do not have an unpriviliged user and run as root
if test "$USER" = root
	set UNPRIVUSER (stern (arg -u) $SUDO_USER)

	if test -z $UNPRIVUSER
		abort 'Has to be run via sudo or a user has to be passed via -u'
	else if not getent passwd $UNPRIVUSER > /dev/null
		abort "User $UNPRIVUSER does not exist!"
	end
else
	abort 'Has to be run as root'
end

# Prepare everything else
set NAME (basename "$SRCDIR")

set PRERUN false
set POSTRUN false

set AURDIR (runuser -u $UNPRIVUSER -- mktemp -d)
set AURBUILDDIR (runuser -u $UNPRIVUSER -- mktemp -d)
set BUILDDIR (mktemp -d)

set AUR "$SRCDIR/aur.deps"
set ARCH "$SRCDIR/arch.deps"
set AURBUILD "$SRCDIR/aur.build.deps"
set ARCHBUILD "$SRCDIR/arch.build.deps"

set ROOTFS "$SRCDIR/rootfs"
set PRESCRIPT "$SRCDIR/pre"
set POSTSCRIPT "$SRCDIR/post"
set BUILDSCRIPT "$SRCDIR/build"
set MANIFEST "$SRCDIR/manifest"

# Set verbosity
if arg -v
	set chipsVerbose true
end

# Cleanup once the script exits
function cleanup --on-process %self
	if test "$JUSTHELPED" != true
		echo "Cleaning Up"

		# Clean up pre script if neccessary
		if test "$PRERUN" = true -a "$POSTRUN" = false
			runPostScript
		end

		# Clean up remaining folders
		rm -rf $BUILDDIR
		rm -rf $AURDIR
		rm -rf $AURBUILDDIR

		echo 'Done'
	end
end

# Run all steps
run "Validating Manifest" validateManifest; or exit
run "Extracting Labels" extractLabels; or exit
run "Setting Up rootfs" bootstrapRootFS; or exit
run "Running pre Script" runPreScript; or exit
run "Installing Arch Dependencies" installDepsArch; or exit
run "Installing Aur Dependencies" installDepsAur; or exit
run "Installing Arch Packages" installArch; or exit
run "Installing Aur Packages" installAur; or exit
run "Copying over rootfs" copyRootFS; or exit
run "Running build Script" runBuildScript; or exit
run "Running post Script" runPostScript; or exit
run "Removing Dependencies" removeDeps; or exit
run "Copying Manifest" copyManifest; or exit
run "Building ACI" buildACI; or exit
