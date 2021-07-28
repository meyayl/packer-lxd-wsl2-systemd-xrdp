# build minor version
variable "version" {
  type    = string
  default = "1.0"
}

# install features in container
variable "desktop" {
  type    = string
  default = "true"
}

variable "install_lxd" {
  type    = string
  default = "true"
}

variable "custom_script" {
  type    = string
  default = "custom-script.sh"
}

# configure image target
variable "wsl" {
  type    = string
  default = "true"
}

# configure packer execution
variable "update" {
  type    = string
  default = "true"
}

variable "apt_cacher" {
  type    = string
  default = "http://192.168.200.31:3142/"
}

variable "cleanup_pause" {
  type    = string
  default = ""
}

variable "hostname" {
  type    = string
  default = "vagrant"
}

variable "vm_name" {
  type    = string
  default = "ubuntu2004"
}

variable "install_vagrant_key" {
  type    = string
  default = "true"
}

variable "vagrantfile_template" {
  type    = string
  default = ""
}

variable "ssh_fullname" {
  type    = string
  default = "vagrant"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ftp_proxy" {
  type    = string
  default = "${env("ftp_proxy")}"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}
variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "rsync_proxy" {
  type    = string
  default = "${env("rsync_proxy")}"
}

locals {
  date = formatdate("YYYYMMDD", timestamp())
}
