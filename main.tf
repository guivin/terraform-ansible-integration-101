terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.45.0"
    }
  }
}

variable "do_token" {
  description = "Token to authenticate to DigitalOcean"
  type        = string
  sensitive   = true
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

resource "digitalocean_droplet" "web1" {
  name     = "web1"
  image    = "ubuntu-24-10-x64"
  region   = "nyc2"
  size     = "s-1vcpu-1gb"
  backups  = false
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}

resource "ansible_host" "web1" {
  name   = digitalocean_droplet.web1.ipv4_address
  groups = ["webservers"]
  variables = {
    ansible_user                 = "root"
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
    ansible_python_interpreter   = "/usr/bin/python3"
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
  }
}

output "ipv4_address" {
  value = digitalocean_droplet.web1.ipv4_address
}
