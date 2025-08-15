#!/bin/bash
# K3s Infrastructure Deployment Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TERRAFORM_DIR="./terraform"
ANSIBLE_DIR="./ansible"
K8S_DIR="./k8s"
CONFIG_DIR="./config"

# Functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if ansible is installed
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_warning "kubectl is not installed. You'll need it to manage the K3s cluster."
    fi
    
    # Check if configuration files exist
    if [[ ! -f "$CONFIG_DIR/terraform.tfvars" ]]; then
        print_error "terraform.tfvars not found. Please run ./setup.sh first."
        exit 1
    fi
    
    if [[ ! -f "$CONFIG_DIR/ansible-vars.yml" ]]; then
        print_error "ansible-vars.yml not found. Please run ./setup.sh first."
        exit 1
    fi
    
    print_success "Prerequisites check passed!"
}

deploy_infrastructure() {
    print_status "Deploying K3s infrastructure with Terraform..."
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan deployment
    print_status "Planning Terraform deployment..."
    terraform plan -var-file="../config/terraform.tfvars" -out=tfplan
    
    # Apply deployment
    print_status "Applying Terraform deployment..."
    terraform apply tfplan
    
    # Generate Ansible inventory from Terraform outputs
    print_status "Generating Ansible inventory..."
    terraform output -json > ../ansible/terraform-outputs.json
    
    cd ..
    
    print_success "Infrastructure deployed successfully!"
}

configure_k3s() {
    print_status "Configuring K3s cluster with Ansible..."
    
    cd "$ANSIBLE_DIR"
    
    # Generate dynamic inventory
    print_status "Generating dynamic inventory..."
    python3 inventory/generate_inventory.py
    
    # Run Ansible playbook
    print_status "Running K3s installation playbook..."
    ansible-playbook -i inventory/hosts.yml site-k3s.yml --extra-vars "@../config/ansible-vars.yml"
    
    cd ..
    
    print_success "K3s cluster configured successfully!"
}

deploy_applications() {
    print_status "Deploying applications to K3s..."
    
    # Wait for cluster to be ready
    print_status "Waiting for K3s cluster to be ready..."
    sleep 30
    
    # Get kubeconfig from master node
    print_status "Setting up kubectl access..."
    MASTER_IP=$(cd terraform && terraform output -raw k3s_master_ip | cut -d'/' -f1)
    
    # Copy kubeconfig (assuming SSH key is set up)
    scp ubuntu@$MASTER_IP:/home/ubuntu/.kube/config ~/.kube/k3s-config
    export KUBECONFIG=~/.kube/k3s-config
    
    # Deploy namespaces
    print_status "Creating namespaces..."
    kubectl apply -f "$K8S_DIR/namespaces.yaml"
    
    # Deploy Ollama
    print_status "Deploying Ollama..."
    kubectl apply -f "$K8S_DIR/ollama.yaml"
    
    # Deploy LibreChat
    print_status "Deploying LibreChat..."
    kubectl apply -f "$K8S_DIR/librechat.yaml"
    
    # Generate and deploy MCP servers
    print_status "Generating MCP server deployments..."
    cd "$K8S_DIR"
    ./generate-mcp-servers.sh 5
    
    print_status "Deploying MCP servers..."
    kubectl apply -f ./mcp-servers-generated/all-mcp-servers.yaml
    
    cd ..
    
    print_success "Applications deployed successfully!"
}

check_deployment() {
    print_status "Checking deployment status..."
    
    # Check nodes
    print_status "K3s nodes:"
    kubectl get nodes -o wide
    
    # Check pods
    print_status "All pods:"
    kubectl get pods --all-namespaces
    
    # Check services
    print_status "All services:"
    kubectl get services --all-namespaces
    
    # Check ingresses
    print_status "All ingresses:"
    kubectl get ingress --all-namespaces
    
    # Get service URLs
    print_status "Service URLs:"
    LB_IP=$(cd terraform && terraform output -raw k3s_loadbalancer_ip | cut -d'/' -f1)
    
    echo -e "${GREEN}🌐 Access URLs:${NC}"
    echo -e "  LibreChat: http://$LB_IP/librechat"
    echo -e "  Ollama: http://$LB_IP/ollama"
    echo -e "  MCP Server 1: http://$LB_IP/mcp-server-1"
    echo -e "  MCP Server 2: http://$LB_IP/mcp-server-2"
    echo -e "  MCP Server 3: http://$LB_IP/mcp-server-3"
    echo -e "  MCP Server 4: http://$LB_IP/mcp-server-4"
    echo -e "  MCP Server 5: http://$LB_IP/mcp-server-5"
    echo -e "  HAProxy Stats: http://$LB_IP:8404/stats"
    
    print_success "Deployment check completed!"
}

cleanup() {
    print_warning "Cleaning up resources..."
    
    cd "$TERRAFORM_DIR"
    terraform destroy -var-file="../config/terraform.tfvars" -auto-approve
    cd ..
    
    print_success "Cleanup completed!"
}

show_help() {
    echo "K3s Infrastructure Deployment Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  deploy     Deploy complete K3s infrastructure"
    echo "  infra      Deploy only infrastructure (Terraform)"
    echo "  k3s        Configure only K3s cluster (Ansible)"
    echo "  apps       Deploy only applications (Kubernetes)"
    echo "  check      Check deployment status"
    echo "  cleanup    Destroy all resources"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy          # Full deployment"
    echo "  $0 infra           # Infrastructure only"
    echo "  $0 check           # Check status"
    echo "  $0 cleanup         # Destroy everything"
}

# Main script logic
case "${1:-deploy}" in
    "deploy")
        print_status "Starting full K3s deployment..."
        check_prerequisites
        deploy_infrastructure
        configure_k3s
        deploy_applications
        check_deployment
        print_success "🎉 K3s deployment completed successfully!"
        ;;
    "infra")
        print_status "Deploying infrastructure only..."
        check_prerequisites
        deploy_infrastructure
        print_success "Infrastructure deployment completed!"
        ;;
    "k3s")
        print_status "Configuring K3s cluster only..."
        configure_k3s
        print_success "K3s configuration completed!"
        ;;
    "apps")
        print_status "Deploying applications only..."
        deploy_applications
        print_success "Application deployment completed!"
        ;;
    "check")
        check_deployment
        ;;
    "cleanup")
        read -p "Are you sure you want to destroy all resources? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cleanup
        else
            print_status "Cleanup cancelled."
        fi
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
