provider "ansible" {}

provider "digitalocean" {
  token = var.do_token
}
