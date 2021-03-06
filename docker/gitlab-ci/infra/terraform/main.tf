provider "google" {
  version = "1.4.0"
  credentials = "${file("./credentials/project.json")}"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "gitlab-branch" {
  name         = "${var.vm_name}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["puma-default"]

  metadata {
    ssh-keys = "appuser:${var.public_key_path}"
  }

  boot_disk {
    initialize_params {
      image = "docker-base"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # ephemeral
    }
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${var.private_key_path}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d -p 9292:9292 ${var.hub_docker_image}"
    ]
  }
}
