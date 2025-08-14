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
  ami_regions   = ["us-west-2", "us-east-1", "us-west-1"]
  
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


<summary>📋 View Sample Build Output</summary>


<div class="scroll-container">
    <pre>
PS C:\Users\OneDrive\Documents\test\ami-Creation> packer build aws-ubuntu.pkr.hcl
amazon-ebs.ubuntu: output will be in this color.

==> amazon-ebs.ubuntu: Prevalidating any provided VPC information
==> amazon-ebs.ubuntu: Prevalidating AMI Name: packer-ubuntu-aws-1755178444
    amazon-ebs.ubuntu: Found Image ID: ami-0ac098a0168eb72d0
==> amazon-ebs.ubuntu: Creating temporary keypair: packer_689de5cc-82ec-8f9c-6bb4-d7dcbf9ff1d3
==> amazon-ebs.ubuntu: Creating temporary security group for this instance: packer_689de5d1-a8bd-9d5a-c2e5-1c253813267e
==> amazon-ebs.ubuntu: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> amazon-ebs.ubuntu: Launching a source AWS instance...
    amazon-ebs.ubuntu: Instance ID: i-08409c70d18d9b488
==> amazon-ebs.ubuntu: Waiting for instance (i-08409c70d18d9b488) to become ready...
==> amazon-ebs.ubuntu: Using SSH communicator to connect: 34.219.117.119
==> amazon-ebs.ubuntu: Waiting for SSH to become available...
==> amazon-ebs.ubuntu: Connected to SSH!
==> amazon-ebs.ubuntu: Provisioning with shell script: C:\Users\moham\AppData\Local\Temp\packer-shell2618837059
    amazon-ebs.ubuntu: Installing Updates
    amazon-ebs.ubuntu: Hit:1 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy InRelease
    amazon-ebs.ubuntu: Get:2 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]  
    amazon-ebs.ubuntu: Get:3 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
    amazon-ebs.ubuntu: Get:4 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/universe amd64 Packages [14.1 MB]
    amazon-ebs.ubuntu: Get:5 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
    amazon-ebs.ubuntu: Get:6 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/universe Translation-en [5652 kB]
    amazon-ebs.ubuntu: Get:7 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/universe amd64 c-n-f Metadata [286 kB]
    amazon-ebs.ubuntu: Get:8 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/multiverse amd64 Packages [217 kB]
    amazon-ebs.ubuntu: Get:9 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/multiverse Translation-en [112 kB]
    amazon-ebs.ubuntu: Get:10 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/multiverse amd64 c-n-f Metadata [8372 B]
    amazon-ebs.ubuntu: Get:11 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [2803 kB]
    amazon-ebs.ubuntu: Get:12 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main Translation-en [443 kB]
    amazon-ebs.ubuntu: Get:13 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/restricted amd64 Packages [4163 kB]
    amazon-ebs.ubuntu: Get:14 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/restricted Translation-en [756 kB]
    amazon-ebs.ubuntu: Get:15 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages [1226 kB]
    amazon-ebs.ubuntu: Get:16 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/universe Translation-en [304 kB]
    amazon-ebs.ubuntu: Get:17 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/universe amd64 c-n-f Metadata [28.7 kB]
    amazon-ebs.ubuntu: Get:18 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 Packages [59.5 kB]
    amazon-ebs.ubuntu: Get:19 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/multiverse Translation-en [14.2 kB]
    amazon-ebs.ubuntu: Get:20 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 c-n-f Metadata [592 B]
    amazon-ebs.ubuntu: Get:21 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-backports/main amd64 Packages [68.8 kB]
    amazon-ebs.ubuntu: Get:22 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-backports/main Translation-en [11.4 kB]
    amazon-ebs.ubuntu: Get:23 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-backports/main amd64 c-n-f Metadata [392 B]
    amazon-ebs.ubuntu: Get:24 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-backports/restricted amd64 c-n-f Metadata [116 B]
    amazon-ebs.ubuntu: Get:25 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-backports/universe amd64 Packages [30.0 kB]
    amazon-ebs.ubuntu: Get:26 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-backports/universe Translation-en [16.6 kB]
    amazon-ebs.ubuntu: Get:27 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-backports/universe amd64 c-n-f Metadata [672 B]
    amazon-ebs.ubuntu: Get:28 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-backports/multiverse amd64 c-n-f Metadata [116 B]
    amazon-ebs.ubuntu: Get:29 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages [2558 kB]
    amazon-ebs.ubuntu: Get:30 http://security.ubuntu.com/ubuntu jammy-security/main Translation-en [379 kB]
    amazon-ebs.ubuntu: Get:31 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 Packages [4018 kB]
    amazon-ebs.ubuntu: Get:32 http://security.ubuntu.com/ubuntu jammy-security/restricted Translation-en [732 kB]
    amazon-ebs.ubuntu: Get:33 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 Packages [993 kB]
    amazon-ebs.ubuntu: Get:34 http://security.ubuntu.com/ubuntu jammy-security/universe Translation-en [217 kB]
    amazon-ebs.ubuntu: Get:35 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 c-n-f Metadata [21.7 kB]
    amazon-ebs.ubuntu: Get:36 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 Packages [40.3 kB]
    amazon-ebs.ubuntu: Get:37 http://security.ubuntu.com/ubuntu jammy-security/multiverse Translation-en [8908 B]
    amazon-ebs.ubuntu: Get:38 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 c-n-f Metadata [368 B]
    amazon-ebs.ubuntu: Fetched 39.6 MB in 7s (5873 kB/s)
    amazon-ebs.ubuntu: Reading package lists...
    amazon-ebs.ubuntu: Reading package lists...
    amazon-ebs.ubuntu: Building dependency tree...
    amazon-ebs.ubuntu: Reading state information...
    amazon-ebs.ubuntu: Calculating upgrade...
    amazon-ebs.ubuntu: The following packages will be upgraded:
    amazon-ebs.ubuntu:   apport python3-apport python3-problem-report
    amazon-ebs.ubuntu: 3 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
    amazon-ebs.ubuntu: Need to get 235 kB of archives.
    amazon-ebs.ubuntu: After this operation, 2048 B of additional disk space will be used.
    amazon-ebs.ubuntu: Get:1 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-problem-report all 2.20.11-0ubuntu82.10 
[11.4 kB]
    amazon-ebs.ubuntu: Get:2 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-apport all 2.20.11-0ubuntu82.10 [89.0 kB]
    amazon-ebs.ubuntu: Get:3 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apport all 2.20.11-0ubuntu82.10 [135 kB]        
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Dialog
==> amazon-ebs.ubuntu: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Readline
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Readline
==> amazon-ebs.ubuntu: debconf: (This frontend requires a controlling tty.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Teletype
==> amazon-ebs.ubuntu: dpkg-preconfigure: unable to re-open stdin:
    amazon-ebs.ubuntu: Fetched 235 kB in 0s (1395 kB/s)
    amazon-ebs.ubuntu: (Reading database ... 65985 files and directories currently installed.)
    amazon-ebs.ubuntu: Preparing to unpack .../python3-problem-report_2.20.11-0ubuntu82.10_all.deb ...
    amazon-ebs.ubuntu: Unpacking python3-problem-report (2.20.11-0ubuntu82.10) over (2.20.11-0ubuntu82.9) ...
    amazon-ebs.ubuntu: Preparing to unpack .../python3-apport_2.20.11-0ubuntu82.10_all.deb ...
    amazon-ebs.ubuntu: Unpacking python3-apport (2.20.11-0ubuntu82.10) over (2.20.11-0ubuntu82.9) ...
    amazon-ebs.ubuntu: Preparing to unpack .../apport_2.20.11-0ubuntu82.10_all.deb ...
    amazon-ebs.ubuntu: Unpacking apport (2.20.11-0ubuntu82.10) over (2.20.11-0ubuntu82.9) ...
    amazon-ebs.ubuntu: Setting up python3-problem-report (2.20.11-0ubuntu82.10) ...
    amazon-ebs.ubuntu: Setting up python3-apport (2.20.11-0ubuntu82.10) ...
    amazon-ebs.ubuntu: Setting up apport (2.20.11-0ubuntu82.10) ...
    amazon-ebs.ubuntu: apport-autoreport.service is a disabled or a static unit, not starting it.
    amazon-ebs.ubuntu: Processing triggers for man-db (2.10.2-1) ...
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: Running kernel seems to be up-to-date.
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: No services need to be restarted.
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: No containers need to be restarted.
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: No user sessions are running outdated binaries.
    amazon-ebs.ubuntu:
    amazon-ebs.ubuntu: No VM guests are running outdated hypervisor (qemu) binaries on this host.
    amazon-ebs.ubuntu: Reading package lists...
    amazon-ebs.ubuntu: Building dependency tree...
    amazon-ebs.ubuntu: Reading state information...
    amazon-ebs.ubuntu: The following additional packages will be installed:
    amazon-ebs.ubuntu:   fontconfig-config fonts-dejavu-core libdeflate0 libfontconfig1 libgd3
    amazon-ebs.ubuntu:   libjbig0 libjpeg-turbo8 libjpeg8 libnginx-mod-http-geoip2
    amazon-ebs.ubuntu:   libnginx-mod-http-image-filter libnginx-mod-http-xslt-filter
    amazon-ebs.ubuntu:   libnginx-mod-mail libnginx-mod-stream libnginx-mod-stream-geoip2 libtiff5
    amazon-ebs.ubuntu:   libwebp7 libxpm4 nginx-common nginx-core
    amazon-ebs.ubuntu: Suggested packages:
    amazon-ebs.ubuntu:   libgd-tools fcgiwrap nginx-doc ssl-cert
    amazon-ebs.ubuntu: The following NEW packages will be installed:
    amazon-ebs.ubuntu:   fontconfig-config fonts-dejavu-core libdeflate0 libfontconfig1 libgd3
    amazon-ebs.ubuntu:   libjbig0 libjpeg-turbo8 libjpeg8 libnginx-mod-http-geoip2
    amazon-ebs.ubuntu:   libnginx-mod-http-image-filter libnginx-mod-http-xslt-filter
    amazon-ebs.ubuntu:   libnginx-mod-mail libnginx-mod-stream libnginx-mod-stream-geoip2 libtiff5
    amazon-ebs.ubuntu:   libwebp7 libxpm4 nginx nginx-common nginx-core
    amazon-ebs.ubuntu: 0 upgraded, 20 newly installed, 0 to remove and 0 not upgraded.
    amazon-ebs.ubuntu: Need to get 2693 kB of archives.
    amazon-ebs.ubuntu: After this operation, 8346 kB of additional disk space will be used.
    amazon-ebs.ubuntu: Get:1 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/main amd64 fonts-dejavu-core all 2.37-2build1 [1041 kB]
    amazon-ebs.ubuntu: Get:2 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/main amd64 fontconfig-config all 2.13.1-4.2ubuntu5 [29.1 kB]
    amazon-ebs.ubuntu: Get:3 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/main amd64 libdeflate0 amd64 1.10-2 [70.9 kB]
    amazon-ebs.ubuntu: Get:4 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/main amd64 libfontconfig1 amd64 2.13.1-4.2ubuntu5 [131 kB]
    amazon-ebs.ubuntu: Get:5 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/main amd64 libjpeg-turbo8 amd64 2.1.2-0ubuntu1 [134 kB]
    amazon-ebs.ubuntu: Get:6 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy/main amd64 libjpeg8 amd64 8c-2ubuntu10 [2264 B]
    amazon-ebs.ubuntu: Get:7 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libjbig0 amd64 2.1-3.1ubuntu0.22.04.1 [29.2 kB] 
    amazon-ebs.ubuntu: Get:8 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libwebp7 amd64 1.2.2-2ubuntu0.22.04.2 [206 kB]  
    amazon-ebs.ubuntu: Get:9 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libtiff5 amd64 4.3.0-6ubuntu0.10 [185 kB]
    amazon-ebs.ubuntu: Get:10 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libxpm4 amd64 1:3.5.12-1ubuntu0.22.04.2 [36.7 kB]
    amazon-ebs.ubuntu: Get:11 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libgd3 amd64 2.3.0-2ubuntu2.3 [129 kB]
    amazon-ebs.ubuntu: Get:12 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 nginx-common all 1.18.0-6ubuntu14.6 [40.1 kB]  
    amazon-ebs.ubuntu: Get:13 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnginx-mod-http-geoip2 amd64 1.18.0-6ubuntu14.6 [12.0 kB]
    amazon-ebs.ubuntu: Get:14 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnginx-mod-http-image-filter amd64 1.18.0-6ubuntu14.6 [15.5 kB]
    amazon-ebs.ubuntu: Get:15 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnginx-mod-http-xslt-filter amd64 1.18.0-6ubuntu14.6 [13.8 kB]
    amazon-ebs.ubuntu: Get:16 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnginx-mod-mail amd64 1.18.0-6ubuntu14.6 [45.8 kB]
    amazon-ebs.ubuntu: Get:17 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnginx-mod-stream amd64 1.18.0-6ubuntu14.6 [73.0 kB]
    amazon-ebs.ubuntu: Get:18 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 libnginx-mod-stream-geoip2 amd64 1.18.0-6ubuntu14.6 [10.1 kB]
    amazon-ebs.ubuntu: Get:19 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 nginx-core amd64 1.18.0-6ubuntu14.6 [483 kB]
    amazon-ebs.ubuntu: Get:20 http://us-west-2.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 nginx amd64 1.18.0-6ubuntu14.6 [3882 B]
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Dialog
==> amazon-ebs.ubuntu: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Readline
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Readline
==> amazon-ebs.ubuntu: debconf: (This frontend requires a controlling tty.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Teletype
==> amazon-ebs.ubuntu: dpkg-preconfigure: unable to re-open stdin:
    amazon-ebs.ubuntu: Fetched 2693 kB in 0s (8511 kB/s)
    amazon-ebs.ubuntu: Selecting previously unselected package fonts-dejavu-core.
    amazon-ebs.ubuntu: (Reading database ... 65985 files and directories currently installed.)
    amazon-ebs.ubuntu: Preparing to unpack .../00-fonts-dejavu-core_2.37-2build1_all.deb ...
    amazon-ebs.ubuntu: Unpacking fonts-dejavu-core (2.37-2build1) ...
    amazon-ebs.ubuntu: Selecting previously unselected package fontconfig-config.
    amazon-ebs.ubuntu: Preparing to unpack .../01-fontconfig-config_2.13.1-4.2ubuntu5_all.deb ...
    amazon-ebs.ubuntu: Unpacking fontconfig-config (2.13.1-4.2ubuntu5) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libdeflate0:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../02-libdeflate0_1.10-2_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libdeflate0:amd64 (1.10-2) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libfontconfig1:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../03-libfontconfig1_2.13.1-4.2ubuntu5_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libfontconfig1:amd64 (2.13.1-4.2ubuntu5) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libjpeg-turbo8:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../04-libjpeg-turbo8_2.1.2-0ubuntu1_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libjpeg-turbo8:amd64 (2.1.2-0ubuntu1) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libjpeg8:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../05-libjpeg8_8c-2ubuntu10_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libjpeg8:amd64 (8c-2ubuntu10) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libjbig0:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../06-libjbig0_2.1-3.1ubuntu0.22.04.1_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libjbig0:amd64 (2.1-3.1ubuntu0.22.04.1) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libwebp7:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../07-libwebp7_1.2.2-2ubuntu0.22.04.2_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libwebp7:amd64 (1.2.2-2ubuntu0.22.04.2) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libtiff5:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../08-libtiff5_4.3.0-6ubuntu0.10_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libtiff5:amd64 (4.3.0-6ubuntu0.10) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libxpm4:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../09-libxpm4_1%3a3.5.12-1ubuntu0.22.04.2_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libxpm4:amd64 (1:3.5.12-1ubuntu0.22.04.2) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libgd3:amd64.
    amazon-ebs.ubuntu: Preparing to unpack .../10-libgd3_2.3.0-2ubuntu2.3_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libgd3:amd64 (2.3.0-2ubuntu2.3) ...
    amazon-ebs.ubuntu: Selecting previously unselected package nginx-common.
    amazon-ebs.ubuntu: Preparing to unpack .../11-nginx-common_1.18.0-6ubuntu14.6_all.deb ...
    amazon-ebs.ubuntu: Unpacking nginx-common (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libnginx-mod-http-geoip2.
    amazon-ebs.ubuntu: Preparing to unpack .../12-libnginx-mod-http-geoip2_1.18.0-6ubuntu14.6_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libnginx-mod-http-geoip2 (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libnginx-mod-http-image-filter.
    amazon-ebs.ubuntu: Preparing to unpack .../13-libnginx-mod-http-image-filter_1.18.0-6ubuntu14.6_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libnginx-mod-http-image-filter (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libnginx-mod-http-xslt-filter.
    amazon-ebs.ubuntu: Preparing to unpack .../14-libnginx-mod-http-xslt-filter_1.18.0-6ubuntu14.6_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libnginx-mod-http-xslt-filter (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libnginx-mod-mail.
    amazon-ebs.ubuntu: Preparing to unpack .../15-libnginx-mod-mail_1.18.0-6ubuntu14.6_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libnginx-mod-mail (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libnginx-mod-stream.
    amazon-ebs.ubuntu: Preparing to unpack .../16-libnginx-mod-stream_1.18.0-6ubuntu14.6_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libnginx-mod-stream (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Selecting previously unselected package libnginx-mod-stream-geoip2.
    amazon-ebs.ubuntu: Preparing to unpack .../17-libnginx-mod-stream-geoip2_1.18.0-6ubuntu14.6_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking libnginx-mod-stream-geoip2 (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Selecting previously unselected package nginx-core.
    amazon-ebs.ubuntu: Preparing to unpack .../18-nginx-core_1.18.0-6ubuntu14.6_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking nginx-core (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Selecting previously unselected package nginx.
    amazon-ebs.ubuntu: Preparing to unpack .../19-nginx_1.18.0-6ubuntu14.6_amd64.deb ...
    amazon-ebs.ubuntu: Unpacking nginx (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Setting up libxpm4:amd64 (1:3.5.12-1ubuntu0.22.04.2) ...
    amazon-ebs.ubuntu: Setting up libdeflate0:amd64 (1.10-2) ...
    amazon-ebs.ubuntu: Setting up nginx-common (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: debconf: unable to initialize frontend: Dialog
    amazon-ebs.ubuntu: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
    amazon-ebs.ubuntu: debconf: falling back to frontend: Readline
    amazon-ebs.ubuntu: Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /lib/systemd/system/nginx.service.
    amazon-ebs.ubuntu: Setting up libjbig0:amd64 (2.1-3.1ubuntu0.22.04.1) ...
    amazon-ebs.ubuntu: Setting up libnginx-mod-http-xslt-filter (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Setting up fonts-dejavu-core (2.37-2build1) ...
    amazon-ebs.ubuntu: Setting up libjpeg-turbo8:amd64 (2.1.2-0ubuntu1) ...
    amazon-ebs.ubuntu: Setting up libwebp7:amd64 (1.2.2-2ubuntu0.22.04.2) ...
    amazon-ebs.ubuntu: Setting up libnginx-mod-http-geoip2 (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Setting up libjpeg8:amd64 (8c-2ubuntu10) ...
    amazon-ebs.ubuntu: Setting up libnginx-mod-mail (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Setting up fontconfig-config (2.13.1-4.2ubuntu5) ...
    amazon-ebs.ubuntu: Setting up libnginx-mod-stream (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Setting up libtiff5:amd64 (4.3.0-6ubuntu0.10) ...
    amazon-ebs.ubuntu: Setting up libfontconfig1:amd64 (2.13.1-4.2ubuntu5) ...
    amazon-ebs.ubuntu: Setting up libnginx-mod-stream-geoip2 (1.18.0-6ubuntu14.6) ...
    amazon-ebs.ubuntu: Setting up libgd3:amd64 (2.3.0-2ubuntu2.3) ...
    amazon-ebs.ubuntu: Setting up libnginx-mod-http-image-filter (1.18.0-6ubuntu14.6) ..
    </pre>
</div>





</details>

🎉 **Success**: You now have Nginx-enabled AMIs in three regions!
