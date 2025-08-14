# Lab 03: Packer Post-Processors - Artifact Management and Tracking

This lab demonstrates how to use Packer post-processors to manage and track artifacts created during the build process. Post-processors run after the image is built and provisioned, providing capabilities for artifact management, documentation, and distribution.

## Prerequisites

- Completed Lab 01 (Basic Packer Template)
- Completed Lab 02 (Provisioners)
- AWS account with appropriate permissions
- Understanding of JSON format

## Duration
⏱️ **30 minutes**

---

## Lab Overview

This lab consists of three main tasks:

- **Task 1**: Add manifest post-processor for artifact tracking
- **Task 2**: Validate the enhanced Packer template
- **Task 3**: Build AMI and analyze the generated manifest

---

## What are Post-Processors?

Post-processors are components that run **after** the builder creates the image and **after** all provisioners have finished configuring it. They operate on the artifacts produced by builders and can perform various operations such as:

### Common Post-Processor Types:

🔧 **Manifest**: Creates a JSON file listing all artifacts produced
📦 **Compress**: Creates compressed archives of artifacts
🚀 **Shell-Local**: Runs commands on the local machine after build
📤 **Artifice**: Re-packages existing artifacts
🌐 **Docker**: Manages Docker container artifacts
☁️ **Cloud Upload**: Uploads artifacts to cloud storage

### Post-Processor Workflow:

```
Builder → Provisioner(s) → Post-Processor(s) → Final Artifacts
```

---

## Why Use the Manifest Post-Processor?

The manifest post-processor is particularly valuable for:

✅ **Multi-Build Tracking**: Keep track of artifacts across multiple builds  
✅ **Automation Integration**: Parse artifact IDs for downstream automation  
✅ **Audit Trail**: Maintain records of what was built and when  
✅ **CI/CD Integration**: Feed artifact information to deployment pipelines  
✅ **Documentation**: Generate reports of build outputs

---

## Task 1: Add Manifest Post-Processor

### Step 1.1: Understanding the Manifest Post-Processor

The manifest post-processor writes a JSON file containing:
- **Build Details**: Builder type, build time, and configuration
- **Artifact IDs**: AMI IDs, container names, or file paths
- **Metadata**: Build UUIDs, custom data, and timestamps

### Step 1.2: Update Your Template

Add the manifest post-processor to your `aws-ubuntu01.pkr.hcl` file:

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

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # System updates and software installation
  provisioner "shell" {
    inline = [
      "echo 'Installing Updates'",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y nginx"
    ]
  }

  # Manifest post-processor to track artifacts
  post-processor "manifest" {
    output = "packer-manifest.json"
    strip_path = true
  }
}
```

### Key Configuration Options:

- **`output`**: Specifies the manifest file name (default: `packer-manifest.json`)
- **`strip_path`**: Removes path information from file artifacts for cleaner output

---

## Task 2: Validate the Enhanced Template

### Step 2.1: Format and Validate

Always ensure your template is properly formatted and valid:

```bash
packer fmt aws-ubuntu01.pkr.hcl 
packer validate aws-ubuntu01.pkr.hcl
```

✅ **Expected Output**: `The configuration is valid.`

### Step 2.2: Verify Template Structure

Your template now includes:
- **Source Block**: Defines the base AMI and build configuration
- **Build Block**: Contains provisioners and post-processors
- **Provisioner**: Installs system updates and Nginx
- **Post-Processor**: Creates artifact manifest

---

## Task 3: Build AMI and Analyze Manifest

### Step 3.1: Execute the Build

Run the build command to create your AMI with manifest tracking:

```bash
packer build aws-ubuntu01.pkr.hcl
```

### Step 3.2: Verify Manifest Creation

After the build completes, check for the manifest file:

```bash
ls -la
```

**Expected Output:**
```bash
total 16
drwxr-xr-x  4 user  staff   128 Dec 15 10:30 .
drwxr-xr-x  8 user  staff   256 Dec 15 10:25 ..
-rw-r--r--  1 user  staff  1234 Dec 15 10:30 aws-ubuntu01.pkr.hcl
-rw-r--r--  1 user  staff   654 Dec 15 10:30 packer-manifest.json
```

✅ **Success Indicator**: The `packer-manifest.json` file should be present

### Step 3.3: Analyze the Manifest

View the contents of the generated manifest:

```bash
cat packer-manifest.json
```

**Sample Manifest Output:**
```json
{
  "builds": [
    {
      "name": "ubuntu",
      "builder_type": "amazon-ebs",
      "build_time": 1702647123,
      "files": null,
      "artifact_id": "eu-central-1:ami-0b70b458400c49bb3,us-east-1:ami-00c645bf39a7a66c2,us-west-2:ami-03b71c51298c1dc68",
      "packer_run_uuid": "136c7fbe-248e-d454-3f7a-ea39c873792e",
      "custom_data": null
    }
  ],
  "last_run_uuid": "136c7fbe-248e-d454-3f7a-ea39c873792e"
}
```

### Step 3.4: Understanding Manifest Fields

| Field | Description | Example Value |
|-------|-------------|---------------|
| **`name`** | Build name from source block | `"ubuntu"` |
| **`builder_type`** | Type of builder used | `"amazon-ebs"` |
| **`build_time`** | Unix timestamp of build completion | `1702647123` |
| **`files`** | Local files created (null for AMIs) | `null` |
| **`artifact_id`** | Comma-separated list of created AMI IDs | `"region:ami-id,region:ami-id"` |
| **`packer_run_uuid`** | Unique identifier for this build run | `"136c7fbe-248e-d454-3f7a-ea39c873792e"` |
| **`custom_data`** | User-defined metadata | `null` |

---

## Advanced Post-Processor Configurations

### Multiple Post-Processors

You can chain multiple post-processors:

```hcl
build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = ["echo 'Build completed'"]
  }

  # Generate manifest
  post-processor "manifest" {
    output = "build-manifest.json"
  }

  # Run local commands after build
  post-processor "shell-local" {
    inline = [
      "echo 'Build completed at: $(date)'",
      "echo 'AMI IDs created:' && jq -r '.builds[].artifact_id' build-manifest.json"
    ]
  }
}
```

### Custom Manifest Output

Customize the manifest file location and name:

```hcl
post-processor "manifest" {
  output     = "artifacts/build-${timestamp()}.json"
  strip_path = true
  custom_data = {
    build_version = "1.0.0"
    environment   = "production"
  }
}
```

---

## Practical Use Cases

### 1. **CI/CD Pipeline Integration**

Extract AMI IDs for deployment automation:

```bash
# Extract AMI ID for specific region
AMI_ID=$(jq -r '.builds[0].artifact_id' packer-manifest.json | grep 'us-west-2' | cut -d':' -f2)
echo "Deploying AMI: $AMI_ID"
```

### 2. **Infrastructure as Code**

Update Terraform variables with new AMI IDs:

```bash
# Update Terraform variables file
echo "ami_id = \"$(jq -r '.builds[0].artifact_id' packer-manifest.json | cut -d',' -f1 | cut -d':' -f2)\"" > terraform.tfvars
```

### 3. **Build Verification**

Verify successful multi-region deployment:

```bash
# Count created AMIs
AMI_COUNT=$(jq -r '.builds[0].artifact_id' packer-manifest.json | tr ',' '\n' | wc -l)
echo "Created $AMI_COUNT AMIs across regions"
```

---

## Troubleshooting

### Common Issues:

**Manifest File Not Created**
- Verify post-processor syntax in template
- Check for build failures before post-processor execution
- Ensure proper permissions in output directory

**Empty or Invalid JSON**
- Validate template with `packer validate`
- Check for syntax errors in post-processor block
- Verify build completed successfully

**Missing AMI IDs**
- Confirm AMIs were actually created in AWS console
- Check AWS permissions for AMI creation
- Verify multi-region copying completed

---

## Best Practices

### 📝 **Documentation**
- Include manifest files in version control for audit trails
- Use descriptive output filenames with timestamps
- Document the purpose of each post-processor

### 🔒 **Security**
- Don't include sensitive data in custom_data fields
- Use IAM roles instead of embedding credentials
- Regularly clean up old manifest files

### 🚀 **Automation**
- Parse manifest files in deployment scripts
- Validate artifact creation before proceeding
- Use manifest data for rollback procedures

---

## Complete Template Example

<details>
<summary>📄 View Complete aws-ubuntu01.pkr.hcl with Post-Processor</summary>

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

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # System updates and software installation
  provisioner "shell" {
    inline = [
      "echo 'Installing Updates'",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y nginx"
    ]
  }

  # Manifest post-processor for artifact tracking
  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
    custom_data = {
      build_version = "1.0.0"
      created_by    = "packer-lab-03"
    }
  }

  # Optional: Local shell commands after build
  post-processor "shell-local" {
    inline = [
      "echo 'Build completed successfully!'",
      "echo 'Manifest created: packer-manifest.json'",
      "jq '.' packer-manifest.json"
    ]
  }
}
```

</details>

---

## Next Steps

Now that you've mastered post-processors, consider exploring:

- **Compress Post-Processor**: Create archives of build artifacts
- **Docker Post-Processors**: Manage container images
- **Custom Post-Processors**: Build your own post-processing logic
- **Integration Testing**: Automatically test created AMIs
- **Multi-Cloud Builds**: Use post-processors across different cloud providers

---

## Additional Resources

- 📚 [Packer Post-Processors Documentation](https://www.packer.io/docs/post-processors)
- 🔧 [Manifest Post-Processor Reference](https://www.packer.io/docs/post-processors/manifest)
- 📊 [Shell-Local Post-Processor](https://www.packer.io/docs/post-processors/shell-local)
- 🛠️ [JQ Manual](https://stedolan.github.io/jq/manual/) - For JSON processing
- ☁️ [AWS CLI Reference](https://docs.aws.amazon.com/cli/) - For AMI management

---

## Contributing

Found an issue or want to improve this lab? Please open an issue or submit a pull request!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.