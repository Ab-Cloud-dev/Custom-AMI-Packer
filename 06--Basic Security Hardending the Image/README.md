# Packer + Ansible AWS AMI Builder (Basic Hardening)

A streamlined workflow for building customized Ubuntu AMIs using Packer and Ansible with basic security hardening. This project demonstrates infrastructure-as-code best practices without external collections, making it perfect for learning and professional portfolios.

## 🌟 Overview

This project creates immutable AMIs with:
- Custom file deployment
- Basic SSH security hardening
- Automated provisioning using Ansible
- Clean, reproducible builds

**Why This Approach:**
- **Simple & Reliable**: No external dependencies or collections
- **Educational**: Easy to understand each hardening step
- **Customizable**: Clear, readable Ansible tasks you can modify
- **Production-Ready**: Follows infrastructure-as-code principles

## 📁 Project Structure

```
.
├── packer.pkr.hcl          # Main Packer configuration
├── ansible.cfg             # Ansible configuration for reliable provisioning
├── ansible/
│   └── playbooks/
│       └── main.yml        # Basic hardening playbook
├── scripts/
│   └── validate.sh         # AMI validation script
└── README.md               # This documentation
```

## 📋 Prerequisites

- [Packer](https://www.packer.io/downloads) (v1.8+)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (v4.0+)
- AWS CLI configured with appropriate permissions
- AWS EC2 Key Pair created

**Required AWS Permissions:**
- EC2: Create/terminate instances, create/delete AMIs
- IAM: Pass role (if using IAM instance profile)
- VPC: Access to subnets and security groups

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd packer-ansible-basic-hardening
```

### 2. Configure AWS Settings
Edit `packer.pkr.hcl` and update these variables:
```hcl
variable "region" {
  default = "us-east-1"  # Your preferred region
}

variable "source_ami" {
  default = "ami-0c02fb55956c7d316"  # Latest Ubuntu 22.04 LTS
}

variable "subnet_id" {
  default = "subnet-xxxxxxxxx"  # Your subnet ID
}

variable "security_group_id" {
  default = "sg-xxxxxxxxx"  # Your security group ID
}

variable "ssh_keypair_name" {
  default = "your-key-pair"  # Your EC2 key pair name
}

variable "ssh_private_key_file" {
  default = "~/.ssh/your-key-pair.pem"  # Path to your private key
}
```

### 3. Initialize and Build
```bash
# Initialize Packer plugins
packer init .

# Build the AMI
PACKER_LOG=1 packer build packer.pkr.hcl
```

### 4. Validate Your AMI
```bash
# Launch an instance from your new AMI
aws ec2 run-instances --image-id <your-new-ami-id> --instance-type t3.micro --key-name your-key-pair

# SSH into the instance and run validation
chmod +x scripts/validate.sh
./scripts/validate.sh
```

## 🔧 What Gets Applied

### Basic Security Hardening
- **SSH Hardening**:
  - Disable root login via SSH
  - Disable password authentication (key-only access)
  - Restart SSH service to apply changes

### Custom Configuration
- Creates `/home/ubuntu/helloworld.txt` for verification
- Sets proper file ownership and permissions

### System Cleanup
- Removes package caches and temporary files
- Optimizes AMI size

## 📝 Configuration Files

### `ansible.cfg`
```ini
[defaults]
host_key_checking = False
ansible_python_interpreter = /usr/bin/python3

[ssh_connection]
transfer_method = scp
scp_if_ssh = True
scp_extra_args = -O
pipelining = False
```

**Key Features:**
- Disables host key checking for automation
- Uses SCP for reliable file transfers
- Prevents common SSH connection issues

### `ansible/playbooks/main.yml`
```yaml
---
- name: Configure and Harden Ubuntu EC2 instance
  hosts: all
  become: yes
  tasks:
    - name: Create verification file
      copy:
        content: "Hello, World! AMI created on {{ ansible_date_time.iso8601 }}"
        dest: /home/ubuntu/helloworld.txt
        owner: ubuntu
        group: ubuntu
        mode: "0644"
    
    - name: Disable root login via SSH
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PermitRootLogin'
        line: 'PermitRootLogin no'
        backup: yes
      notify: restart ssh
    
    - name: Disable password authentication
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PasswordAuthentication'
        line: 'PasswordAuthentication no'
        backup: yes
      notify: restart ssh
  
  handlers:
    - name: restart ssh
      service:
        name: ssh
        state: restarted
```

## ✅ Validation & Testing

### Automated Validation
Run the included validation script:
```bash
# On your new instance
./scripts/validate.sh
```

### Manual Validation Steps
1. **File Verification**:
   ```bash
   ls -la /home/ubuntu/helloworld.txt
   cat /home/ubuntu/helloworld.txt
   ```

2. **SSH Hardening Check**:
   ```bash
   sudo grep -E "(PermitRootLogin|PasswordAuthentication)" /etc/ssh/sshd_config
   ```

3. **Security Test**:
   ```bash
   # This should fail (good!)
   ssh -o PreferredAuthentications=password root@localhost
   ```

### Expected Results
- ✅ `helloworld.txt` exists with timestamp
- ✅ `PermitRootLogin no` in SSH config
- ✅ `PasswordAuthentication no` in SSH config
- ✅ SSH service running and configured
- ✅ Root login attempts fail

## 🔍 Troubleshooting

### Common Issues

**Build fails with "ansible-galaxy not found"**
- Solution: This version doesn't use collections, so this shouldn't occur

**SSH connection timeouts during build**
- Check security group allows SSH (port 22) from Packer instance
- Verify subnet and instance can reach each other
- Ensure private key permissions: `chmod 400 ~/.ssh/your-key.pem`

**Ansible tasks fail with permission errors**
- Verify `become: yes` is set in playbook
- Check that the SSH user has sudo privileges

### Debug Mode
For detailed logging:
```bash
PACKER_LOG=1 packer build packer.pkr.hcl
```

### Testing Playbook Separately
```bash
# Test on a running instance
ansible-playbook -i <instance-ip>, -u ubuntu --private-key ~/.ssh/your-key.pem ansible/playbooks/main.yml -v
```

## 🚀 Next Steps & Enhancements

### Add More Hardening
```yaml
# Add to your playbook
- name: Configure firewall
  ufw:
    state: enabled
    policy: deny
    direction: incoming

- name: Allow SSH through firewall
  ufw:
    rule: allow
    port: ssh
```

### Advanced Features to Consider
- **Package Updates**: Automatic security patching
- **Log Configuration**: Enhanced logging and monitoring
- **User Management**: Create service accounts
- **Certificate Management**: SSL/TLS certificate deployment
- **Compliance Scanning**: Integration with AWS Inspector

### Scaling Up
- Use [DevSec hardening collections](https://github.com/dev-sec/ansible-collection-hardening) for comprehensive security
- Implement CI/CD pipeline for automated AMI builds
- Add multiple OS support (CentOS, Amazon Linux)
- Create AMI testing frameworks

## 📊 Best Practices Implemented

| Practice | Implementation | Benefit |
|----------|----------------|---------|
| Immutable Infrastructure | AMI-based deployments | Consistent, reproducible instances |
| Infrastructure as Code | Packer + Ansible configuration | Version-controlled infrastructure |
| Security by Default | SSH hardening in base image | Reduced attack surface |
| Automated Validation | Validation scripts | Catch issues early |
| Clean Builds | Cleanup provisioners | Optimized AMI sizes |
| Clear Documentation | Comprehensive README | Easy onboarding and maintenance |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Test your changes with: `packer validate packer.pkr.hcl`
4. Commit changes: `git commit -m 'Add amazing feature'`
5. Push to branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Useful Resources

- [Packer Documentation](https://www.packer.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [AWS AMI Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
- [SSH Security Hardening](https://stribika.github.io/2015/01/04/secure-secure-shell.html)
- [CIS Ubuntu Benchmarks](https://www.cisecurity.org/benchmark/ubuntu_linux)

## 📈 Monitoring & Maintenance

### AMI Lifecycle Management
- Set up automated builds for security patches
- Use AWS Systems Manager for patch compliance
- Implement AMI deregistration policies for old images

### Security Monitoring
- Enable AWS CloudTrail for AMI usage tracking
- Use AWS Config for compliance monitoring
- Consider AWS Inspector for vulnerability scanning

---

**Built with ❤️ for Infrastructure as Code Learning**

*This project serves as a foundation for understanding AMI automation. Start here, then expand with additional security controls and automation as needed.*