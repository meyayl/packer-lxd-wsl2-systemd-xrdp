source "lxd" "ubuntu" {
  image        = "ubuntu-minimal:20.04"
  output_image = var.vm_name
  publish_properties = {
    version = "20.04"
    architecture = "amd64"
    description = "ubuntu 20.04 LTS amd64 (custom) (${local.date})"
    label = "myaylaci/ubuntu2004"
    os = "ubuntu"
    release = "focal"
    serial = local.date
    type = "squashfs"
  }
}

source "lxc" "ubuntu" {
  config_file = "/etc/lxc/default.conf"
  template_name = "download"
  template_parameters = [
      "--dist", "ubuntu",
      "--release","focal",
      "--arch", "amd64",
      "--variant", "default",
      "--no-validate"
  ]
  output_directory         = "output-${var.vm_name}-lxc"
}

build {
  sources = [
    "source.lxc.ubuntu",
    "source.lxd.ubuntu"
  ]

  provisioner "shell" {
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    expect_disconnect = "true"
    pause_before      = "10s"
    environment_vars  = [
      "CLEANUP_PAUSE=${var.cleanup_pause}",
      "DEBIAN_FRONTEND=noninteractive",
      "DESKTOP=${var.desktop}",
      "UPDATE=${var.update}",
      "APT_CACHER=${var.apt_cacher}",
      "INSTALL_VAGRANT_KEY=${var.install_vagrant_key}",
      "SSH_USERNAME=${var.ssh_username}",
      "SSH_PASSWORD=${var.ssh_password}",
      "http_proxy=${var.http_proxy}",
      "https_proxy=${var.https_proxy}",
      "ftp_proxy=${var.ftp_proxy}",
      "rsync_proxy=${var.rsync_proxy}",
      "no_proxy=${var.no_proxy}"
    ]
    scripts           = [
      "script/update.sh",
      "script/sshd.sh",
      "script/vagrant.sh",
      "script/basics.sh",
      "script/motd.sh",
      "script/wsl.sh",
      "script/desktop.sh",
      "script/install_lxd.sh",
      var.custom_script,
      "script/minimize.sh",
      "script/cleanup.sh"
    ]
  }

  #post-processor "vagrant" {
  #  keep_input_artifact  = true
  #  output               = "box/{{.Provider}}/${var.vm_name}-${local.date}.${var.version}.box"
  #  vagrantfile_template = "${var.vagrantfile_template}"
  #}
}
