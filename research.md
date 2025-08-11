# AMI selection for Deep Learning AMI with Conda (Ubuntu 22.04)
data "aws_ami" "gpu_dlami_conda" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning AMI GPU PyTorch *Ubuntu*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Alternative: Base DLAMI for custom installations
data "aws_ami" "gpu_dlami_base" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 22.04)*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Multi-framework DLAMI
data "aws_ami" "gpu_dlami_multiframework" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning AMI (Ubuntu 22.04)*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# For Ubuntu 24.04 (newer version)
data "aws_ami" "gpu_dlami_ubuntu24" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 24.04)*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Output the selected AMI details
output "selected_dlami_id" {
  value = data.aws_ami.gpu_dlami_conda.id
}

output "selected_dlami_name" {
  value = data.aws_ami.gpu_dlami_conda.name
}

output "selected_dlami_description" {
  value = data.aws_ami.gpu_dlami_conda.description
}


Let me fetch more detailed information about DLAMIs to provide you with comprehensive details.Let me fetch more information about the current DLAMI naming conventions and supported versions.Based on the documentation and current information about AWS Deep Learning AMIs, here's a comprehensive overview:

## AWS Deep Learning AMI (DLAMI) Overview

AWS Deep Learning AMIs (DLAMI) provides customized machine images that you can use for deep learning in the cloud. The DLAMIs are available in most AWS Regions for a variety of Amazon Elastic Compute Cloud (Amazon EC2) instance types, from a small CPU-only instance to the latest high-powered multi-GPU instances. The DLAMIs come preconfigured with NVIDIA CUDA and NVIDIA cuDNN and the latest releases of the most popular deep learning frameworks.

## DLAMI Types and Versions

There are several types of DLAMIs available:

1. **Deep Learning AMI with Conda** - These DLAMIs support Ubuntu 20.04, Ubuntu 22.04, Amazon Linux 2, Amazon Linux 2023 Operating systems

2. **Deep Learning Base AMI** - Minimal installations for custom builds

3. **Neuron Deep Learning AMI** - For AWS Inferentia and Trainium instances

## Current Supported Operating Systems

Ubuntu 20.04, Ubuntu 22.04, Amazon Linux 2, Amazon Linux 2023, with Ubuntu 24.04 also available based on recent releases.

## Updated Terraform AMI Search

Here's an updated Terraform configuration that reflects the current DLAMI naming conventions:## Key Changes from Your Original Configuration:

1. **Updated naming patterns**: The current DLAMI naming conventions have evolved. Instead of "Deep Learning AMI GPU *Ubuntu 22.04*", the current patterns include:
   - "Deep Learning AMI GPU PyTorch *Ubuntu*" for PyTorch-specific AMIs
   - "Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 22.04)*" for base AMIs
   - "Deep Learning AMI (Ubuntu 22.04)*" for multi-framework AMIs

2. **Added state filter**: Ensures only available AMIs are selected

3. **Multiple options**: Provided different DLAMI types for different use cases:
   - **Conda DLAMI**: Pre-configured with frameworks in conda environments
   - **Base DLAMI**: Minimal setup for custom installations
   - **Multi-framework**: Contains multiple deep learning frameworks
   - **Ubuntu 24.04**: Latest Ubuntu version support

4. **Support for newer versions**: Ubuntu 24.04 is now available in addition to Ubuntu 22.04

## Recommended Usage:

- Use the **Conda DLAMI** for most deep learning workloads as it comes pre-configured with popular frameworks
- Use the **Base DLAMI** if you need custom framework installations or specific versions
- The naming patterns may continue to evolve, so consider using broader wildcards in your filters

The configuration above will help you find the most recent compatible DLAMI for your deep learning workloads on AWS.