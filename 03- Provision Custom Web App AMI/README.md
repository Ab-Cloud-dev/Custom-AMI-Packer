
## Task 1: Deploy Custom Web Application

### Step : Prepare Application Assets

First, create a directory for your web application files:

```bash
mkdir assets
cd assets
```

Download the sample web application assets:
```bash
# Clone or download from the repository
wget https://github.com/btkrausen/hashicorp/archive/master.zip
unzip master.zip
cp -r hashicorp-master/packer/assets/* .
cd ..
```

**Alternative**: Create your own `setup-web.sh` script in the `assets` directory:

```bash
#!/bin/bash
# setup-web.sh - Custom web application setup script

echo "Setting up custom web application..."

# Install additional packages if needed
sudo apt-get update
sudo apt-get install -y nginx

# Copy web files to nginx directory
sudo cp -r /tmp/assets/web/* /var/www/html/ 2>/dev/null || echo "No web files found"

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure firewall (if ufw is installed)
sudo ufw allow 'Nginx Full' 2>/dev/null || echo "UFW not configured"

echo "Web application setup complete!"
```

### Step  2: Update Build Block with File Provisioner

Replace your existing build block with this enhanced version:

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # System updates
  provisioner "shell" {
    inline = [
      "echo Installing Updates",
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  # Copy application files
  provisioner "file" {
    source      = "assets"
    destination = "/tmp/"
  }

  # Setup web application
  provisioner "shell" {
    inline = [
      "sudo sh /tmp/assets/setup-web.sh"
    ]
  }
}
```

### Step 3: Validate and Build

Validate the updated template:

```bash
packer fmt aws-ubuntu01.pkr.hcl 
packer validate aws-ubuntu01.pkr.hcl
```

<img width="929" height="380" alt="image" src="https://github.com/user-attachments/assets/fe3bda7c-282f-4b91-895d-1c4bc8b40420" />


Build the final AMI with your custom web application:

```bash
packer build packer.pkr.hcl
```

---

## Complete Template Example

<details>
  <summary>📄 View Complete OUTPUT</summary>
    <div style="max-height: 200px; overflow-y: scroll;">
      <ul>

amazon-ebs.ubuntu: output will be in this color.

==> amazon-ebs.ubuntu: Prevalidating any provided VPC information
==> amazon-ebs.ubuntu: Prevalidating AMI Name: packer-ubuntu-aws-1755189740
==> amazon-ebs.ubuntu: Found Image ID: ami-021589336d307b577
==> amazon-ebs.ubuntu: Creating temporary keypair: packer_689e11ec-f4aa-0732-42f6-daaa8e005de5
==> amazon-ebs.ubuntu: Creating temporary security group for this instance: packer_689e11ec-0800-293f-d2a6-84d9aaada367
==> amazon-ebs.ubuntu: Authorizing access to port 22 from [0.0.0.0/0] in the temporary security groups...
==> amazon-ebs.ubuntu: Launching a source AWS instance...
==> amazon-ebs.ubuntu: Instance ID: i-08bb63aa42680a154
==> amazon-ebs.ubuntu: Waiting for instance (i-08bb63aa42680a154) to become ready...
==> amazon-ebs.ubuntu: Using SSH communicator to connect: 3.81.111.40
==> amazon-ebs.ubuntu: Waiting for SSH to become available...
==> amazon-ebs.ubuntu: Connected to SSH!
==> amazon-ebs.ubuntu: Provisioning with shell script: /tmp/packer-shell2322113201
==> amazon-ebs.ubuntu: Installing Updates
==> amazon-ebs.ubuntu: Get:1 http://security.ubuntu.com/ubuntu jammy-security InRelease [129 kB]
==> amazon-ebs.ubuntu: Hit:2 http://archive.ubuntu.com/ubuntu jammy InRelease
==> amazon-ebs.ubuntu: Get:3 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [128 kB]
==> amazon-ebs.ubuntu: Get:4 http://archive.ubuntu.com/ubuntu jammy-backports InRelease [127 kB]
==> amazon-ebs.ubuntu: Get:5 http://archive.ubuntu.com/ubuntu jammy/universe amd64 Packages [1 1 MB]
==> amazon-ebs.ubuntu: Get:6 http://security.ubuntu.com/ubuntu jammy-security/main amd64 Packages [2558 kB]
==> amazon-ebs.ubuntu: Get:7 http://security.ubuntu.com/ubuntu jammy-security/main Translation-en [379 kB]
==> amazon-ebs.ubuntu: Get:8 http://security.ubuntu.com/ubuntu jammy-security/restricted amd64 Packages [4018 kB]
==> amazon-ebs.ubuntu: Get:9 http://security.ubuntu.com/ubuntu jammy-security/restricted Translation-en [732 kB]
==> amazon-ebs.ubuntu: Get:10 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 Packages [993 kB]
==> amazon-ebs.ubuntu: Get:11 http://security.ubuntu.com/ubuntu jammy-security/universe Translation-en [217 kB]
==> amazon-ebs.ubuntu: Get:12 http://security.ubuntu.com/ubuntu jammy-security/universe amd64 c-n-f Metadata [21.7 kB]
==> amazon-ebs.ubuntu: Get:13 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 Packages [40.3 kB]
==> amazon-ebs.ubuntu: Get:14 http://security.ubuntu.com/ubuntu jammy-security/multiverse Translation-en [8908 B]
==> amazon-ebs.ubuntu: Get:15 http://security.ubuntu.com/ubuntu jammy-security/multiverse amd64 c-n-f Metadata [368 B]
==> amazon-ebs.ubuntu: Get:16 http://archive.ubuntu.com/ubuntu jammy/universe Translation-en [5652 kB]
==> amazon-ebs.ubuntu: Get:17 http://archive.ubuntu.com/ubuntu jammy/universe amd64 c-n-f Metadata [286 kB]
==> amazon-ebs.ubuntu: Get:18 http://archive.ubuntu.com/ubuntu jammy/multiverse amd64 Packages [217 kB]
==> amazon-ebs.ubuntu: Get:19 http://archive.ubuntu.com/ubuntu jammy/multiverse Translation-en [112 kB]
==> amazon-ebs.ubuntu: Get:20 http://archive.ubuntu.com/ubuntu jammy/multiverse amd64 c-n-f Metadata [8372 B]
==> amazon-ebs.ubuntu: Get:21 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [2803 kB]
==> amazon-ebs.ubuntu: Get:22 http://archive.ubuntu.com/ubuntu jammy-updates/main Translation-en [443 kB]
==> amazon-ebs.ubuntu: Get:23 http://archive.ubuntu.com/ubuntu jammy-updates/restricted amd64 Packages [4163 kB]
==> amazon-ebs.ubuntu: Get:24 http://archive.ubuntu.com/ubuntu jammy-updates/restricted Translation-en [756 kB]
==> amazon-ebs.ubuntu: Get:25 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 Packages [1226 kB]
==> amazon-ebs.ubuntu: Get:26 http://archive.ubuntu.com/ubuntu jammy-updates/universe Translation-en [304 kB]
==> amazon-ebs.ubuntu: Get:27 http://archive.ubuntu.com/ubuntu jammy-updates/universe amd64 c-n-f Metadata [28.7 kB]
==> amazon-ebs.ubuntu: Get:28 http://archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 Packages [59.5 kB]
==> amazon-ebs.ubuntu: Get:29 http://archive.ubuntu.com/ubuntu jammy-updates/multiverse Translation-en [1 2 kB]
==> amazon-ebs.ubuntu: Get:30 http://archive.ubuntu.com/ubuntu jammy-updates/multiverse amd64 c-n-f Metadata [592 B]
==> amazon-ebs.ubuntu: Get:31 http://archive.ubuntu.com/ubuntu jammy-backports/main amd64 Packages [68.8 kB]
==> amazon-ebs.ubuntu: Get:32 http://archive.ubuntu.com/ubuntu jammy-backports/main Translation-en [11.4 kB]
==> amazon-ebs.ubuntu: Get:33 http://archive.ubuntu.com/ubuntu jammy-backports/main amd64 c-n-f Metadata [392 B]
==> amazon-ebs.ubuntu: Get:34 http://archive.ubuntu.com/ubuntu jammy-backports/restricted amd64 c-n-f Metadata [116 B]
==> amazon-ebs.ubuntu: Get:35 http://archive.ubuntu.com/ubuntu jammy-backports/universe amd64 Packages [30.0 kB]
==> amazon-ebs.ubuntu: Get:36 http://archive.ubuntu.com/ubuntu jammy-backports/universe Translation-en [16.6 kB]
==> amazon-ebs.ubuntu: Get:37 http://archive.ubuntu.com/ubuntu jammy-backports/universe amd64 c-n-f Metadata [672 B]
==> amazon-ebs.ubuntu: Get:38 http://archive.ubuntu.com/ubuntu jammy-backports/multiverse amd64 c-n-f Metadata [116 B]
==> amazon-ebs.ubuntu: Fetched 39.6 MB in 11s (3702 kB/s)
==> amazon-ebs.ubuntu: Reading package lists...
==> amazon-ebs.ubuntu: Reading package lists...
==> amazon-ebs.ubuntu: Building dependency tree...
==> amazon-ebs.ubuntu: Reading state information...
==> amazon-ebs.ubuntu: Calculating upgrade...
==> amazon-ebs.ubuntu: The following packages have been kept back:
==> amazon-ebs.ubuntu:   snapd
==> amazon-ebs.ubuntu: The following packages will be upgraded:
==> amazon-ebs.ubuntu:   apport python3-apport python3-problem-report
==> amazon-ebs.ubuntu: 3 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
==> amazon-ebs.ubuntu: Need to get 235 kB of archives.
==> amazon-ebs.ubuntu: After this operation, 2048 B of additional disk space will be used.
==> amazon-ebs.ubuntu: Get:1 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-problem-report all 2.20.11-0ubuntu82.10 [11.4 kB]
==> amazon-ebs.ubuntu: Get:2 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 python3-apport all 2.20.11-0ubuntu82.10 [89.0 kB]
==> amazon-ebs.ubuntu: Get:3 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy-updates/main amd64 apport all 2.20.11-0ubuntu82.10 [135 kB]
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Dialog
==> amazon-ebs.ubuntu: debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buffer, or without a controlling terminal.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Readline
==> amazon-ebs.ubuntu: debconf: unable to initialize frontend: Readline
==> amazon-ebs.ubuntu: debconf: (This frontend requires a controlling tty.)
==> amazon-ebs.ubuntu: debconf: falling back to frontend: Teletype
==> amazon-ebs.ubuntu: dpkg-preconfigure: unable to re-open stdin:
==> amazon-ebs.ubuntu: Fetched 235 kB in 0s (1521 kB/s)
==> amazon-ebs.ubuntu: (Reading database ... 65985 files and directories currently installed.)
==> amazon-ebs.ubuntu: Preparing to unpack .../python3-problem-report_2.20.11-0ubuntu82.10_all.deb ...
==> amazon-ebs.ubuntu: Unpacking python3-problem-report (2.20.11-0ubuntu82.10) over (2.20.11-0ubuntu82.9) ...
==> amazon-ebs.ubuntu: Preparing to unpack .../python3-apport_2.20.11-0ubuntu82.10_all.deb ...
==> amazon-ebs.ubuntu: Unpacking python3-apport (2.20.11-0ubuntu82.10) over (2.20.11-0ubuntu82.9) ...
==> amazon-ebs.ubuntu: Preparing to unpack .../apport_2.20.11-0ubuntu82.10_all.deb ...
==> amazon-ebs.ubuntu: Unpacking apport (2.20.11-0ubuntu82.10) over (2.20.11-0ubuntu82.9) ...
==> amazon-ebs.ubuntu: Setting up python3-problem-report (2.20.11-0ubuntu82.10) ...
==> amazon-ebs.ubuntu: Setting up python3-apport (2.20.11-0ubuntu82.10) ...
==> amazon-ebs.ubuntu: Setting up apport (2.20.11-0ubuntu82.10) ...
==> amazon-ebs.ubuntu: apport-autoreport.service is a disabled or a static unit, not starting it.
==> amazon-ebs.ubuntu: Processing triggers for man-db (2.10.2-1) ...
==> amazon-ebs.ubuntu:
==> amazon-ebs.ubuntu: Running kernel seems to be up-to-date.
==> amazon-ebs.ubuntu:
==> amazon-ebs.ubuntu: No services need to be restarted.
==> amazon-ebs.ubuntu:
==> amazon-ebs.ubuntu: No containers need to be restarted.
==> amazon-ebs.ubuntu:
==> amazon-ebs.ubuntu: No user sessions are running outdated binaries.
==> amazon-ebs.ubuntu:
==> amazon-ebs.ubuntu: No VM guests are running outdated hypervisor (qemu) binaries on this host.
==> amazon-ebs.ubuntu: Uploading ./assets => /tmp/
==> amazon-ebs.ubuntu: Provisioning with shell script: /tmp/packer-shell1626984543
==> amazon-ebs.ubuntu: Created symlink /etc/systemd/system/multi-user.target.wants/webapp.service → /lib/systemd/system/webapp.service.
==> amazon-ebs.ubuntu: Stopping the source instance...
==> amazon-ebs.ubuntu: Stopping instance
==> amazon-ebs.ubuntu: Waiting for the instance to stop...
==> amazon-ebs.ubuntu: Creating AMI packer-ubuntu-aws-1755189740 from instance i-08bb63aa42680a154
==> amazon-ebs.ubuntu: Attaching run tags to AMI...
==> amazon-ebs.ubuntu: AMI: ami-075c18447244f490e
==> amazon-ebs.ubuntu: Waiting for AMI to become ready...
==> amazon-ebs.ubuntu: Skipping Enable AMI deprecation...
==> amazon-ebs.ubuntu: Skipping Enable AMI deregistration protection...
==> amazon-ebs.ubuntu: Adding tags to AMI (ami-075c18447244f490e)...
==> amazon-ebs.ubuntu: Tagging snapshot: snap-0036112a5eb3f5c03
==> amazon-ebs.ubuntu: Creating AMI tags
==> amazon-ebs.ubuntu: Adding tag: "Created-by": "Packer"
==> amazon-ebs.ubuntu: Adding tag: "Environment": "Production"
==> amazon-ebs.ubuntu: Adding tag: "Name": "MyUbuntuImage"
==> amazon-ebs.ubuntu: Adding tag: "OS_Version": "Ubuntu 22.04"
==> amazon-ebs.ubuntu: Adding tag: "Release": "Latest"
==> amazon-ebs.ubuntu: Creating snapshot tags
==> amazon-ebs.ubuntu: Terminating the source AWS instance...
==> amazon-ebs.ubuntu: Cleaning up any extra volumes...
==> amazon-ebs.ubuntu: No volumes to clean up, skipping
==> amazon-ebs.ubuntu: Deleting temporary security group...
==> amazon-ebs.ubuntu: Deleting temporary keypair...
Build 'amazon-ebs.ubuntu' finished after 4 minutes 54 seconds.

==> Wait completed after 4 minutes 54 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu: AMIs were created:
us-east-1: ami-075c18447244f490e

   </ul>
  </div>
</details>

## AMI Details 

<img width="1676" height="798" alt="image" src="https://github.com/user-attachments/assets/27ffb5a2-9cc6-4084-886f-3611e02dc424" />

## Instance Created From the AMI

<img width="1728" height="849" alt="image" src="https://github.com/user-attachments/assets/2e920819-f0f7-43e4-a942-a5343dd4601c" />

## Acessing the Page from Public IP 

<img width="1638" height="875" alt="image" src="https://github.com/user-attachments/assets/c1dcc04c-7bc6-4db3-828c-20642798cb2a" />



---

## Key Concepts Learned

### Provisioner Types Used:

1. **Shell Provisioner**
   - Executes commands directly on the instance
   - Perfect for system updates and package installation
   - Can run inline commands or external scripts

2. **File Provisioner**
   - Copies files from local machine to instance
   - Supports individual files or entire directories
   - Essential for deploying application code

### Best Practices:

✅ **Separate Concerns**: Use multiple provisioner blocks for different tasks
✅ **Error Handling**: Include error checking in shell scripts
✅ **Idempotency**: Ensure scripts can run multiple times safely
✅ **Logging**: Add echo statements for build visibility

---

## Troubleshooting

### Common Issues:

**File Not Found Errors**
- Verify `assets` directory exists and contains required files
- Check file paths in provisioner configurations

**Permission Denied**
- Ensure scripts have execute permissions: `chmod +x setup-web.sh`
- Use `sudo` for system-level operations

**Package Installation Failures**
- Always run `apt-get update` before installing packages
- Handle non-interactive installs with `-y` flag

---

## Testing Your AMI

After the build completes, test your AMI:

1. **Launch Instance**: Create an EC2 instance from your new AMI
2. **Verify Services**: Check that Nginx is running: `sudo systemctl status nginx`
3. **Test Web Access**: Visit the instance's public IP to verify web application

---

## Next Steps

Now that you've mastered provisioners, consider exploring:

- Adding configuration management (Ansible, Chef, Puppet)
- Implementing secrets management for sensitive data
- Creating parameterized templates with variables
- Adding post-processors for artifact management
- Implementing comprehensive testing strategies

---

## Additional Resources

- 📚 [Packer Provisioners Documentation](https://www.packer.io/docs/provisioners)
- 🛠️ [Shell Provisioner Reference](https://www.packer.io/docs/provisioners/shell)
- 📁 [File Provisioner Reference](https://www.packer.io/docs/provisioners/file)
- ☁️ [AWS AMI Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)

---

## Contributing

Found an issue or want to improve this lab? Please open an issue or submit a pull request!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
