# packer-lxd-wsl2-systemd-xrdp

This repository contains a [Packer](https://packer.io/) template to create a WSL2 Ubuntu box according Vagrant conventions.

Note: For time beeing vagrant does not support a wsl provider, as such the convention is met for future use (if ever implemented). Though, it works regardless in WSL2 and WSLg.

The project is inspired by and directly uses artefacts from following projects:
- xWSL (https://github.com/DesktopECHO/xWSL)
- ubuntu-wsl2-systemd-script (https://github.com/FiestaLake/ubuntu-wsl2-systemd-script)
- boxcutter (https://github.com/boxcutter/ubuntu)

### Overview

The target image contains:
- systemd
- ubuntu-wsl
- mesa > 21.3
- xrdp 
- xfce 4.16
- pulseaudio
- epiphany-browser

WSLInterop works out of the box.
On WSLg, thanks to WSLInterop, xrdp will leverage hardware accelaration provided by /dev/xdg.

Note: Re-using the unix daemon socket of the WSLg host vm prevents the start of xrdp. 
      For time beeing hardware accelerated WSLg is slower than software rendered WSL2.

      When microsoft's patches to wayland, weston and freerdp are merged with the upstream projects,
      It is concidered to migrate from xrdp to freerdp to leverage all wslg optimzations.

## Building the WSL box with Packer

To build the WSL box, you need a [LXD](https://linuxcontainers.org) host. This can either be any WSL2 Distro with enabled systemd and LXD, or any Linux Distro that supports LXD. The build is tested on WSL2 Ubuntu 20.04 with enabled systemd and LXD. If you not already have a WSL2 Distro with enabled systemd, you can use `make enable_systemd_on_wsl2` to enable systemd for the running distro. Please follow the instructions on screen, as it might become necessary to set Windows environment variables in order for this method to work.


The packer configuration uses HCL2 Packer templates and leverages the packer bash provisioner to perfom the actions.

### Precondition

The Makefile includes variables that can be customized:

```
export export_wsl_image := ubuntu2004
export output_wsl_image_path := ${HOME}/wsl-ubuntu2004.tar.gz
export wsl_source_path := /mnt/c/wsldistros/sources/
export wsl_distribution := lxd
```

Change the values however you need them.

Make sure a recent Packer version is installed. The Makefile has a target for Ubuntu/Debian machines:

```
    # make install_packer
```
Since the Ubuntu20.04 minimal lxc container is used as base, the repository needs to be import before the first build:

```
    # make import_image_repo
```

### Build LXD image

```
    # make build_lxd_image
```

### Export WSL2 image

```
    # make export_lxd_wsl2_image
```
### Packer Proxy Settings

The templates respect the following network proxy environment variables
and forward them on to the container environment during the image creation
process, should you be using a proxy:

* http_proxy
* https_proxy
* ftp_proxy
* rsync_proxy
* no_proxy

### Packer Variable overrides

There are several variables that can be used to override some of the default
settings in the box build process. 

The variable `UPDATE` can be used to perform OS patch management.  The
default is to not apply OS updates by default.  When `UPDATE := true`,
the latest OS updates will be applied.

The variables `SSH_USERNAME` and `SSH_PASSWORD` can be used to change the
 default name & password from the default `vagrant`/`vagrant` respectively.

The variable `INSTALL_VAGRANT_KEY` can be set to turn off installation of the
default insecure vagrant key when the image is being used outside of vagrant.
Set `INSTALL_VAGRANT_KEY := false`, the default is true.

The variable `CUSTOM_SCRIPT` can be used to specify a custom script
to be executed. You can add it to the `script/custom` directory (content
is ignored by Git).
The default is `custom-script.sh` which does nothing.

## Import and run the Image as WSL2 Distribution
### Change WSL2 "entrypoint script"
Manually run the two commands in Windows's cmd.exe:

```
    setx WSLENV BASH_ENV/u
    setx BASH_ENV /etc/bash.bashrc
```
The first command adds the variable BASH_ENV to the list of variables passed from the windows host to the WSL2 distribution.
The second commands sets the variable BASH_ENV to execute `/etc/bash.bashrc` when starting the WSL2 distribution.

This is required to enable Systemd services when starting the distribution!

### Import WSL2 distribution
Run the commands to import the image as distribution in WSL2:

```
    wsl.exe--import <name of the imported distribution> <installation folder for vhdx> <filename> [options]
```

Example:

```
    wsl.exe --import myDistribution  C:\wsldistros\sources\myDistribution C:\wsldistros\sources\myDistribution.tar.gz --version 2
```
Replace "myDistribution" with the name you want to name you imported distribution.

Then start the container as usual with `wsl -d myDistribution` or `wsl --distribution myDistribution`

### Connect to XRDP
Open mstsc aka remotedesktop and expand the options. Set the computername to `localhost`
Set the username to `vagrant` and the password to `vagrant`.

Enable the shared clipboard as needed.

Note: to enable device sharing (which is unnecessary due to WSLInterop) make sure only drives are shared within the connection.
If other devices are shared, the resource sharing becomes ineffective and nothing becomes shared!


## Known Issues

- xrdp commes disabled by default. During first start of the WSL2 Distribution, the xrdp service will enabled and reconfigured, to prevent brakeage.

## Contributing

1. Fork and clone the repo.
2. Create a new branch, please don't work in your `master` branch directly.
3. FiSx stuff.
4. Update `README.md` and `AUTHORS` to reflect any changes.
5. If you have a large change in mind, it is still preferred that you split them into small commits.  Good commit messages are important.  The git documentatproject has some nice guidelines on [writing descriptive commit messages](http://git-scm.com/book/ch5-2.html#Commit-Guidelines).
6. Push to your fork and submit a pull request.

