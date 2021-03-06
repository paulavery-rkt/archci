# archci(1) -- Script to build app container images based on Archlinux packages

## SYNOPSIS

	archci [-h|--help] [-v|--verbose] SRCDIR TRGDIR


## DESCRIPTION
This Script allows you to build [AppContainer](https://coreos.com/rkt/docs/0.5.6/app-container.html) images. It takes advantage of the existing Arch Linux ecosystem, and allows you to install either repository packages or packages from the AUR.
You call the script with a source folder and a target directory. The source folder contains all the neccessary configuration for your appcontainer Image.

### SRCDIR STRUCTURE
A set of files can be placed inside the source directory to instruct this application on how to build the ACI.
The files with the `.deps` extension declare the archlinux packages to be installed. A single packagename should be provide on each line.
The containers rootfs is initialized by installing the `filesystem` package via `pacstrap -cdGM`.
Due to the fact, that we try to create a minimal container image, we do not install the `base` or `base-devel` groups. If a package you install depends on any packages from these groups, you may have to specify them explicitly.

* `manifest`:
	The source directory should contain, at an absolute minimum, a valid appcontainer image [manifest](https://github.com/appc/spec/blob/master/spec/aci.md#image-manifest).

	If you omit the `version` label in the manifest, the script will try to extract the version of the first aur or repo package. It will patch it into the copied manifest.

	The provided `app.user` and `app.group` fields will be resolved against the targets user/group mappings. If not possible, keeps the set value. This should be handled by rkt at some point (according to spec) but currently isn't.

* `arch.deps`:
	A list of packages from the arch repositories. Installed by pacman with the `-r` flag. This means your local pacman configurtion will be used.
	It also means your local keyring is used to verify everything.

* `aur.deps`:
	A list of packages to install from the aur. The packages will be build with pacaur on your local system. They will then be installed with `pacman -r`.

* `arch.build.deps`:
	Repository packages defined in this file will be uninstalled after your setup script is run. You may think of these like build dependencies.

* `aur.build.deps`:
	Like `arch.build.deps` for aur packages.

* `rootfs`:
	You may provide a `rootfs` folder. Anything contained within will be copied to the acis rootfs after all packages are installed and before your script will be run.

* `pre`:
	An optional setup script which will be run straight after the `rootfs` folder is prepared and before any packages are installed into it. It is called with the `rootfs` path as its first argument.
	You can use it to mount or symlinks things etc.

* `build`:
	An optional setup script/executable may be supplied as `build`. It will be run chrooted into the containers `rootfs` after all package installation and file copying has been completed. You may use it to set up your applications state, generate some random keys, etc.
	Due to the fact that you are chrooted into your new system, you will have to ensure, that any dependencies of your script are installed (including whatever is declared in your shebang). You should use `arch.build.deps` and `aur.build.deps`, so the dependencies will be removed afterwards.

* `post`:
	An optional teardown script which should be used to undo the things done by the `pre` script.
	It is called after the `build` script is run.

### SIGNING
The Script will use `gpg` to sign your generated images. It will use the current users keyring, so make sure it is configured correctly

### OUTPUT
All the work will be done in temporary directories (make sure your tmp folder has enough space available). Once done, the images will be created inside your specified output folder.
The files are named to be easily used by the [aci-discovery](https://github.com/coreos/aci-discovery) server. So basically `builddir/linux/amd64/1.0.0-name.aci`. The arch, os and name will be extracted from the manifest.

## INSTALLATION
The script depends on the [sx](https://www.npmjs.com/package/sx) npm package. It should be either installed globally or into `/usr/lib/archci/node_modules`.

In addition we need `fish`, `pacstrap`, `arch-chroot`, `pacaur`, `actool`, `sudo` and `gpg` installed.

If you are running this script on Arch, you can simply install the [archci](https://aur.archlinux.org/packages/archci/) AUR package.
