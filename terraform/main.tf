provider "google" {
 credentials = "${file("${var.gcp-key-file}")}"
 project     = "${var.project}"
 region      = "${var.region}"
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

data "template_file" "gcp-key" {
  template = "${file(var.gcp-key-file)}"
}

module "automate_password" {
  source = "matti/resource/shell"
  command = "$(uuidgen)"
}

resource "google_compute_instance" "ubuntu-xenial" {
   name = "chef-automate"
   machine_type = "n1-standard-8"
   zone = "${var.zone}"
   boot_disk {
      initialize_params {
      image = "ubuntu-1604-lts"
   }
}

tags = ["https-server"]

network_interface {
   network = "default"
   access_config {
       nat_ip = "${google_compute_address.static.address}"
   }
  }

metadata {
  startup-script = <<SCRIPT
  sudo apt-get update && \
  sudo curl -s https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip | gunzip - > chef-automate && \ 
  sudo chmod +x chef-automate && sudo ./chef-automate init-config && \ 
  sudo sed -i 's/chef-automate.c.${var.project}.internal/${google_compute_address.static.address}/1' config.toml && \ 
  sudo sed -i 's/license = \"\"/license = \"${var.automate-license}\"/1' config.toml && \
  yes | sudo ./chef-automate deploy config.toml --skip-preflight && \
  export TOK=`sudo chef-automate admin-token`
  SCRIPT
  } 
}
