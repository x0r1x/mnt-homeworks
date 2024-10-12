locals {
    sa_key_file = file("~/.yc-bender-key.json")
    ssh_pub_key = file("~/.ssh/id_ed25519.pub")
    ssh_user = "ubuntu"
    cloudinit = templatefile("${path.module}/cloud-init.yml", {
        ssh_public_key = local.ssh_pub_key
    })
}