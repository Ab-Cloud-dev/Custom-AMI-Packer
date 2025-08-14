packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8" // Require Amazon plugin version 1.2.8 or higher
      source  = "github.com/hashicorp/amazon" // Plugin source location
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-aws-{{timestamp}}" // Name of the new AMI, with a timestamp for uniqueness
  instance_type = "t3.micro"                        // EC2 instance type used for building the AMI
  region        = "us-west-2"                       // Primary AWS region for building the AMI
  ami_regions   = ["us-west-2", "us-east-1", "us-west-1"] // List of regions to copy the AMI to after creation

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*" // Filter for Ubuntu 22.04 LTS images
      root-device-type    = "ebs"                                              // Only EBS-backed images
      virtualization-type = "hvm"                                              // Only HVM virtualization
    }
    most_recent = true                 // Use the most recent image that matches the filter
    owners      = ["099720109477"]     // Canonical's AWS account ID (official Ubuntu images)
  }

  ssh_username = "ubuntu" // Default SSH username for Ubuntu AMIs

  tags = {
    "Name"        = "Multi-region-Ubuntu-AMI" // Tag for the AMI name
    "Environment" = "Production"              // Tag for environment
    "OS_Version"  = "Ubuntu 22.04"            // Tag for OS version
    "Release"     = "Latest"                  // Tag for release
    "Created-by"  = "Packer"                  // Tag to indicate AMI was created by Packer
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu" // Reference to the source block above
  ]

  provisioner "shell" {
    inline = [
      "echo Installing Updates",           // Print message to the console
      "sudo apt-get update",               // Update package lists
      "sudo apt-get upgrade -y",           // Upgrade installed packages
      "sudo apt-get install -y nginx"      // Install nginx web server
    ]
  }
}