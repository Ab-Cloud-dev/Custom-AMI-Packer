# Lab 01: Building AWS AMIs with Packer Templates

This lab provides a hands-on introduction to creating custom Amazon Machine Images (AMIs) using HashiCorp Packer. You'll learn how to write Packer HCL templates and build custom Ubuntu images in AWS.

## Prerequisites

- AWS account with appropriate permissions
- AWS CLI configured (optional but recommended)
- Basic understanding of AWS EC2 and AMIs

## Duration
⏱️ **30 minutes**

---

## Setup: Install Packer

1. Download and install Packer from the official HashiCorp website:
   ```
   https://developer.hashicorp.com/packer/install
   ```

2. Verify the installation:
   ```bash
   packer version
   ```

   ![Packer Version Check](https://github.com/user-attachments/assets/2171179f-3dec-41b3-80d4-66624ae30326)

---

## Lab Overview

This lab consists of four main tasks:

- **Task 1**: Create a Source Block
- **Task 2**: Validate the Packer Template  
- **Task 3**: Create a Builder Block
- **Task 4**: Build a Custom AMI

---

## Getting Started

### Create Project Directory

```bash
mkdir packer_templates
cd packer_templates
```

---

## Task 1: Create a Source Block

Source blocks define the virtualization platform, launch configuration, and connection details for your image build process.

### Step 1.1: Create the Packer Template

Create a new file named `aws-ubuntu01.pkr.hcl` with the following content:

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
}
```

### Step 1.2: Initialize Packer

Download the required plugin binaries:

```bash
packer init aws-ubuntu01.pkr.hcl
```

> **Note**: This command downloads the Amazon plugin and should be run whenever working with a new template.

---

## Task 2: Validate the Packer Template

### Step 2.1: Format and Validate

Format your template for consistency and validate its syntax:

```bash
packer fmt aws-ubuntu01.pkr.hcl 
packer validate aws-ubuntu01.pkr.hcl
```

✅ **Expected Output**: The validate command should return `The configuration is valid.`

![Packer Validation Output](https://github.com/user-attachments/assets/0cf58a8f-6218-43f5-9f1a-f45e8867e8e6)

---

## Task 3: Create a Builder Block

Builder blocks define the build process and reference the source configuration.

### Step 3.1: Add Builder Configuration

Append the following builder block to your `aws-ubuntu01.pkr.hcl` file:

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}
```

**Complete Template Structure:**
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
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}
```

---

## Task 4: Build Your Custom AMI

### Step 4.1: Configure AWS Credentials

Before building, ensure your AWS credentials are configured. Choose one of the following methods:

#### Option 1: Environment Variables (Linux/macOS)
```bash
export AWS_ACCESS_KEY_ID=<your-access-key>
export AWS_SECRET_ACCESS_KEY=<your-secret-key>
export AWS_DEFAULT_REGION=us-west-2
```

#### Option 2: Environment Variables (Windows PowerShell)
```powershell
$Env:AWS_ACCESS_KEY_ID="<your-access-key>"
$Env:AWS_SECRET_ACCESS_KEY="<your-secret-key>"
$Env:AWS_DEFAULT_REGION="us-west-2"
```

#### Option 3: AWS CLI Profile
```bash
aws configure
```

![AWS Environment Variables Setup](https://github.com/user-attachments/assets/4609d923-40bd-4157-a237-a96619ed21d9)

### Step 4.2: Execute the Build

Run the Packer build command:

```bash
packer build aws-ubuntu01.pkr.hcl
```

### Expected Build Process

The build will proceed through several phases:

1. **Launch EC2 Instance** - Creates a temporary t3.micro instance
2. **Wait for SSH** - Establishes connection to the instance  
3. **Execute Build Steps** - Runs any provisioners (none in this basic example)
4. **Create AMI** - Snapshots the instance into a custom AMI
5. **Cleanup** - Terminates the temporary instance

🎉 **Success**: Upon completion, you'll have a new custom AMI in your AWS account!

![Packer Build Process](https://github.com/user-attachments/assets/4fab8f33-8741-4586-acc6-461d998dda98)

---

## Important Notes

- **VPC Requirements**: This lab assumes you have the default VPC available. If not, add `vpc_id` and `subnet_id` parameters to your source block
- **Subnet Access**: The subnet must have public access and a valid route to an Internet Gateway
- **Costs**: Building AMIs incurs minimal EC2 costs for the temporary instance runtime

---

## Troubleshooting

### Common Issues

**Authentication Errors**
- Verify AWS credentials are correctly configured
- Ensure your IAM user has necessary EC2 permissions

**Network Issues**
- Check that your default VPC and subnets exist
- Verify security groups allow SSH access

**Template Validation**
- Run `packer validate` before building
- Check for syntax errors in the HCL configuration

---

## Next Steps

Now that you've built a basic AMI, consider exploring:

- Adding provisioners to install software
- Using multiple builders for different regions
- Implementing post-processors for artifact handling
- Creating parameterized templates with variables

---

## Additional Resources

- 📚 [Packer Documentation](https://www.packer.io/docs/index.html)
- 🛠️ [Packer CLI Reference](https://www.packer.io/docs/commands/index.html)
- ☁️ [AWS AMI Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)
- 🔧 [Amazon Builder Documentation](https://www.packer.io/plugins/builders/amazon)

---

## Contributing

Found an issue or want to improve this lab? Please open an issue or submit a pull request!

