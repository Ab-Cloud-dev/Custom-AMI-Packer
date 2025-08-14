// -----------------------------------------------------------------------------
// Variable Definitions for Packer AMI Creation
// -----------------------------------------------------------------------------
// ami_name      : The name to assign to the created Amazon Machine Image (AMI).
// instance_type : The AWS EC2 instance type to use during the build process.
// region        : The AWS region where the AMI will be created.
// ssh_username  : The SSH username for connecting to the instance during provisioning.
// -----------------------------------------------------------------------------
ami_name      = "dev-packer-linux-aws-ubuntu"
instance_type = "t2.micro"
region        = "us-east-1"
ssh_username  = "ubuntu"