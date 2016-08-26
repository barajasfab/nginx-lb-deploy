# nginx load balancer and backend node set up

resource "digitalocean_droplet" "load_balancer" {
  count              = 2
  image              = "${var.image_slug}"
  name               = "${var.project}-lb-${count.index + 1}"
  region             = "${var.region}"
  size               = "2gb"
  private_networking = true
  ssh_keys           = ["${var.keys}"]
  user_data          = "${data.template_file.user_data.rendered}"

  connection {
    user     = "root"
    type     = "ssh"
    key_file = "${var.private_key_path}"
    timeout  = "2m"
  }
}

resource "digitalocean_droplet" "web_node" {
  count              = "${var.node_count}"
  image              = "${var.image_slug}"
  name               = "${var.project}-web-${count.index + 1}"
  region             = "${var.region}"
  size               = "1gb"
  private_networking = true
  ssh_keys           = ["${var.keys}"]
  user_data          = "${data.template_file.user_data.rendered}"

  connection {
    user     = "root"
    type     = "ssh"
    key_file = "${var.private_key_path}"
    timeout  = "2m"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/config/cloud-config.yaml")}"

  vars {
    public_key = "${var.public_key}"
  }
}

resource "digitalocean_floating_ip" "fip" {
  region     = "${var.region}"
  droplet_id = "${digitalocean_droplet.load_balancer.0.id}"
}
