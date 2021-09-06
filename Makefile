MAKEFLAGS += --warn-undefined-variables --no-print-directory
SHELL := bash
.SHELLFLAGS := -e -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

export export_wsl_image := ubuntu2004
export output_wsl_image_path := ${HOME}/wsl-ubuntu2004.tar.gz
export wsl_source_path := /mnt/c/wsldistros/sources/
export wsl_distribution := lxd

.PHONY: all
all:
	@echo "Possible Targets:"
	@less Makefile |grep .PHONY[:] |cut -f2 -d ' ' |xargs -n1 echo " - " |grep -v " -  all"

# ==============================================================================
# Deploy phony's
# ==============================================================================

.PHONY: enable_systemd_on_wsl2
enable_systemd_on_wsl2:
	@git clone https://github.com/meyayl/ubuntu-wsl2-systemd-script.git ~/ubuntu-wsl2-systemd-script \
	&&  ~/ubuntu-wsl2-systemd-script \
	&& bash install.sh

.PHONY: install_packer
install_packer:
	@curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
	@sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $$(lsb_release -cs) main"
	@sudo apt-get update
	@sudo apt-get -y install packer

.PHONY: import_image_repo
import_image_repo:
	@lxc remote add --protocol simplestreams ubuntu-minimal https://cloud-images.ubuntu.com/minimal/releases/

.PHONY: build_lxd_image
build_lxd_image:
	@packer build -only=lxd.ubuntu .

.PHONY: export_lxd_wsl2_image
export_lxd_wsl2_image:
	@while [ -z "$$CONTINUE" ]; do \
		read -r -p "WARNING: This target needs to be run on the host where the lxd image is build. Continue?  [y/n]: " CONTINUE; \
	done; [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Export Aborted!"; exit 1;)
	@echo "Create temp folder" && \
	tmp_folder=$$(mktemp -d) && \
	echo "Export lxd image to temp folder" && \
	lxc image export $(export_wsl_image) $${tmp_folder}/image && \
	echo "Untar lxd image to extract rootfs folder" && \
	tar -xzf $${tmp_folder}/image.tar.gz --same-owner -C "$${tmp_folder}" && \
	pushd "$${tmp_folder}/rootfs" && \
	echo "Tar wsl image from rootfs folder" && \
	tar -czf $(output_wsl_image_path) --same-owner * && \
	popd && \
	echo "Delete temp folder" && \
	sudo rm -rf "$${tmp_folder}" && \
	mkdir -p $(wsl_source_path) && \
	echo "Move wsl image to wsl_source_path" && \
	sudo mv $(output_wsl_image_path) $(wsl_source_path) && \
	export wsl_image_filename=$${output_wsl_image_path##*/} && \
	echo "  import in powershell:" && \
	echo "    wsl.exe --import $(wsl_distribution)  $$(wslpath -w $(wsl_source_path))\$(wsl_distribution) $$(wslpath -w $(wsl_source_path))\$${wsl_image_filename} --version 2" && \
	echo "  start wsl2 container:" && \
	echo "    wsl -d $(wsl_distribution)" && \
	echo "Wait a couple of seconds before accessing it with rdp"
