packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami" {
  type    = string
  default = "ami-080e1f13689e07408" # Update for your region if needed
}

variable "ssh_keypair_name" {
  type    = string
  default = "jj" # Replace with your AWS key pair name
}

variable "ssh_private_key_file" {
  type    = string
  default = "/home/ubuntu/jj.pem" # Path to your .pem file
}

source "amazon-ebs" "ubuntu_test" {
  region               = var.region
  source_ami           = var.source_ami
  instance_type        = "t3.micro"
  ssh_username         = "ubuntu"
  ami_name             = "ubuntu-test-ami-{{timestamp}}"

  ssh_keypair_name     = var.ssh_keypair_name
  ssh_private_key_file = var.ssh_private_key_file
}

build {
  name    = "ubuntu-test"
  sources = ["source.amazon-ebs.ubuntu_test"]

  # 1. Prepare the instance for Ansible
  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y python3",
      "sudo mkdir -p /home/ubuntu/.ansible/tmp",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/.ansible"
    ]
  }

  # 2. Run Ansible with debug-friendly settings
  provisioner "ansible" {
    playbook_file          = "playbook.yml"
    user                   = "ubuntu"
    use_proxy              = false
    ansible_ssh_extra_args = ["-o StrictHostKeyChecking=no"]
    extra_arguments        = ["-vvv", "--extra-vars", "ansible_python_interpreter=/usr/bin/python3"]
  }

  # 3. Clean up to reduce the AMI size
  provisioner "shell" {
    inline = [
      "sudo apt autoremove -y",
      "sudo apt autoclean -y",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /var/cache/*"
    ]
  }
}
