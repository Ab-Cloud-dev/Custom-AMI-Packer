# First Download the Packer 

https://developer.hashicorp.com/packer/install

# Make Sure the Packer is install 


<img width="636" height="107" alt="image" src="https://github.com/user-attachments/assets/2171179f-3dec-41b3-80d4-66624ae30326" />


# Lab: Write a Packer Template


This lab will walk you through updating a Packer HCL Template. It uses the amazon-ebs source to create a custom image in the us-west-2 region of AWS.

Duration: 30 minutes

- Task 1: Create a Source Block
- Task 2: Validate the Packer Template
- Task 3: Create a Builder Block
- Task 4: Build a new Image using Packer

## Creating a Packer Template (optional)
```bash
mkdir packer_templates
cd packer_templates
```

### Task 1: Create a Source Block
Source blocks define what kind of virtualization to use for the image, how to launch the image and how to connect to the image.  Sources can be used across multiple builds.  We will use the `amazon-ebs` source configuration to launch a `t3.micro` AMI in the `us-west-2` region.

### Step 1.1.1

Create a `aws-ubuntu01.pkr.hcl` file with the following Packer `source` block and `required_plugins`.

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

### Step 1.1.2
The `packer init` command is used to download Packer plugin binaries. This is the first command that should be executed when working with a new or existing template. This command is always safe to run multiple times.

```shell
packer init aws-ubuntu.pkr01.hcl
```

### Task 2: Validate the Packer Template
Packer templates can be auto formatted and validated via the Packer command line.

### Step 2.1.1

Format and validate your configuration using the `packer fmt` and `packer validate` commands.

```shell
packer fmt aws-ubuntu01.pkr.hcl 
packer validate aws-ubuntu01.pkr.hcl
```
<img width="880" height="123" alt="image" src="https://github.com/user-attachments/assets/0cf58a8f-6218-43f5-9f1a-f45e8867e8e6" />

### Task 3: Create a Builder Block
Builders are responsible for creating machines and generating images from them for various platforms.  They are use in tandem with the source block within a template.

### Step 3.1.1
Add a builder block to `aws-ubuntu.pkr.hcl` referencing the source specified above.  The source can be referenced usin the HCL interpolation syntax.

```hcl
build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}
```

### Task 4: Build a new Image using Packer
The `packer build` command is used to initiate the image build process for a given Packer template. For this lab, please note that you will need credentials for your AWS account in order to properly execute a `packer build`. You can set your credentials using [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html#linux), using [aws configure](https://docs.aws.amazon.com/cli/latest/reference/configure/) if you have the AWSCLI installed, or [embed the credentials](https://www.packer.io/docs/builders/amazon/ebsvolume#access-configuration) in the template.

> Example using environment variables on a Linux or macOS:

```shell
export AWS_ACCESS_KEY_ID=<your access key>
export AWS_SECRET_ACCESS_KEY=<your secret key>
export AWS_DEFAULT_REGION=us-west-2
```



> Example via Powershell:

```pwsh
PS C:\> $Env:AWS_ACCESS_KEY_ID="<your access key>"
PS C:\> $Env:AWS_SECRET_ACCESS_KEY="<your secret key>"
PS C:\> $Env:AWS_DEFAULT_REGION="us-west-2"
```

<img width="1140" height="187" alt="image" src="https://github.com/user-attachments/assets/4609d923-40bd-4157-a237-a96619ed21d9" />


 


### Step 4.1.1
Run a `packer build` for the `aws-ubuntu.pkr.hcl` template.

```shell

packer build aws-ubuntu01.pkr.hcl

```

Packer will print output similar to what is shown below.


<img width="1001" height="744" alt="image" src="https://github.com/user-attachments/assets/4fab8f33-8741-4586-acc6-461d998dda98" />




**Note:** This lab assumes you have the default VPC available in your account. If you do not, you will need to add the [`vpc_id`](https://www.packer.io/docs/builders/amazon/ebs#vpc_id) and [`subnet_id`](https://www.packer.io/docs/builders/amazon/ebs#subnet_id). The subnet will need to have public access and a valid route to an Internet Gateway.

##### Resources
* Packer [Docs](https://www.packer.io/docs/index.html)
* Packer [CLI](https://www.packer.io/docs/commands/index.html)


