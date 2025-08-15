terraform {
  required_version = ">= 1.0"
  
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
  
  # Uncomment and configure for remote state management
  # backend "s3" {
  #   bucket = "ai-infrastructure-terraform-state"
  #   key    = "proxmox/terraform.tfstate"
  #   region = "us-east-1"
  # }
}
