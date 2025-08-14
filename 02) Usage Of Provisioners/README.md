# Lab 02: Packer Provisioners - Installing Software and Applications

This lab demonstrates how to use Packer provisioners to install software, configure services, and deploy applications on your custom AMIs. You'll learn to use shell provisioners and file provisioners to create production-ready images.

## Prerequisites

- Completed Lab 01 (Basic Packer Template)
- AWS account with appropriate permissions
- Basic understanding of shell scripting

## Duration
⏱️ **30 minutes**

---

## Lab Overview

This lab consists of four main tasks:

- **Task 1**: Add provisioners for system updates and Nginx installation
- **Task 2**: Validate the enhanced Packer template
- **Task 3**: Build AMI with multi-region support
- **Task 4**: Deploy a custom web application

---

## What are Provisioners?

Provisioners use built-in and third-party software to install and configure the machine image after booting. They run after the base image is launched but before the final AMI is created.

### Common Provisioner Types:
- **Shell**: Execute shell commands and scripts
- **File**: Copy files and directories to the instance
- **Ansible**: Run Ansible playbooks
- **PowerShell**: Execute PowerShell scripts (Windows)

---

## Task 1: Add Multi-Region Support and Provisioners

### Step 1.1: Update Source Block with Multi-Region Support

Update your `aws-ubuntu01.pkr.hcl` file to include multiple regions and proper tagging:

```hcl
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-aws-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-west-2"
  ami_regions   = ["us-west-2", "us-east-1", "eu-central-1"]
  
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  
  ssh_username = "ubuntu"
  
  tags = {
    "Name"        = "MyUbuntuImage"
    "Environment" = "Production"
    "OS_Version"  = "Ubuntu 22.04"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}
```

### Step 1.2: Add Shell Provisioner

Add a build block with a shell provisioner to install system updates and Nginx:

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Installing Updates",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y nginx"
    ]
  }
}
```

### Key Features Added:

🌍 **Multi-Region Support**: AMIs will be created in us-west-2, us-east-1, and eu-central-1
🏷️ **Resource Tagging**: Proper tags for identification and management
📦 **Software Installation**: Automated Nginx installation and system updates

---

## Task 2: Validate the Enhanced Template

### Step 2.1: Format and Validate

Always format and validate your templates before building:

```bash
packer fmt aws-ubuntu01.pkr.hcl 
packer validate aws-ubuntu01.pkr.hcl
```

✅ **Expected Output**: `The configuration is valid.`

---

## Task 3: Build Multi-Region AMI

### Step 3.1: Execute the Build

Run the build command to create your enhanced AMI:

```bash
packer build aws-ubuntu01.pkr.hcl
```

### Build Process Overview

The build will proceed through these phases:

1. **🚀 Launch Instance**: Creates temporary EC2 instance
2. **🔗 SSH Connection**: Establishes secure connection
3. **📥 System Updates**: Downloads and installs system updates
4. **🌐 Nginx Installation**: Installs and configures web server
5. **📸 AMI Creation**: Creates AMI in primary region
6. **🌍 Regional Copy**: Copies AMI to additional regions
7. **🏷️ Tagging**: Applies tags to all AMIs and snapshots
8. **🧹 Cleanup**: Terminates temporary resources

<details>
<summary>📋 View Sample Build Output</summary>


<div class="scroll-container">
    <pre>
        // Your long code snippet here
        // ... lots of lines ...
        // ... lots of lines ...
        // ... lots of lines ...
    </pre>
</div>





</details>

🎉 **Success**: You now have Nginx-enabled AMIs in three regions!
