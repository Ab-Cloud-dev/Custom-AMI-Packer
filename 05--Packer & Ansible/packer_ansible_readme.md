# Packer + Ansible AWS AMI Builder

A robust, automated workflow for building customized Ubuntu AMIs using Packer and Ansible. This project demonstrates infrastructure-as-code best practices with immutable infrastructure principles, making it perfect for professional DevOps portfolios.

## 🌟 Why This Approach Works

### 1. Immutable, Reproducible AMIs
Using Packer ensures you always produce a fresh, immutable AMI from a defined input state. This aligns with the principle of immutable infrastructure: rather than patching running servers, you rebuild and redeploy. It's faster, more secure, and less error-prone.

### 2. Robust Provisioning with Ansible
Ansible integrates cleanly with Packer to provision instances during the build. It's more readable, reusable, and idempotent compared to raw shell scripts. Ansible is also widely adopted in the Infrastructure-as-Code ecosystem.

### 3. Reliable File Transfer via SCP
The default method for transferring Ansible modules can fail due to SFTP issues, missing subsystems, or SSH configuration nuances. By explicitly forcing SCP via `ansible.cfg`, we avoid these pitfalls—this is a proven fix for real-world deployments.

## 📁 Project Structure

```
.
├── packer.pkr.hcl          # Core Packer definition with AWS + Ansible plugins
├── ansible.cfg             # Configuration to use SCP and disable SFTP
├── ansible/
│   └── playbook.yml        # Sample Ansible playbook
└── README.md               # Project documentation
```

## 📋 Prerequisites

- [Packer](https://www.packer.io/downloads) installed
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed
- AWS CLI configured with appropriate permissions
- AWS EC2 Key Pair created and accessible

## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd <repo-name>
   ```

2. **Configure your AWS credentials:**
   ```bash
   aws configure
   ```

3. **Update the key pair reference in `packer.pkr.hcl`** to match your AWS key pair name.

4. **Initialize Packer plugins:**
   ```bash
   packer init .
   ```

5. **Build the AMI:**
   ```bash
   PACKER_LOG=1 packer build packer.pkr.hcl
   ```

6. **Validate the build:**
   - Launch a new EC2 instance using the generated AMI
   - Verify that `/home/ubuntu/hello.txt` exists

## 🔧 Configuration Files

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

**Key configurations:**
- Disables host key checking for smoother automation
- Forces SCP over SFTP to avoid transfer failures
- Adds SCP compatibility flags (`-O`)
- Disables pipelining to avoid edge-case SSH issues

### `packer.pkr.hcl`
The main Packer configuration includes:
- **AWS builder**: Configures the source AMI and instance details
- **Shell provisioner**: Installs Python and sets up Ansible's temp directory
- **Ansible provisioner**: Runs the playbook with verbose mode and `use_proxy = false`
- **Cleanup step**: Removes package caches to reduce final image size

### `ansible/playbook.yml`
A minimal demonstration playbook that creates `/home/ubuntu/hello.txt` to verify Ansible provisioning is working correctly.

## 🎯 Best Practices Implemented

| Feature | Benefit |
|---------|---------|
| Scoped plugins in Packer | Cleanly separates builder (AWS) and provisioner (Ansible) logic |
| Immutable AMI builds | Ensures consistency and easier rollback/change control |
| SCP-based file transfer | Avoids Ansible module transfer failures tied to SFTP issues |
| Debug and verbose flags | Enables deep visibility into builds for troubleshooting |
| Cleanup provisioners | Reduces final AMI size by removing temporary and cache files |
| Clear directory structure | Makes the project easy to explore, understand, and extend |

## 🔍 Troubleshooting

### Common Challenges and Solutions

**Problem: Unreliable file transfer failures**
- **Solution**: Our configuration explicitly forces SCP instead of SFTP, avoiding dependency on potentially disabled SFTP subsystems.

**Problem: SSH or permission issues**
- **Solution**: The shell provisioner creates `/home/ubuntu/.ansible/tmp` with correct ownership, ensuring Ansible modules can be uploaded reliably.

**Problem: Proxy interference**
- **Solution**: Setting `use_proxy = false` prevents SSH connections from being misrouted locally.

### Debug Mode
For detailed logging, run:
```bash
PACKER_LOG=1 packer build packer.pkr.hcl
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 References

- [Packer Documentation](https://www.packer.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [AWS AMI Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)

---

**Built with ❤️ for Infrastructure as Code**