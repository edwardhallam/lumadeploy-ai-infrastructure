# GitHub Actions Workflows

## Deploy Workflow (Disabled)

The `deploy.yml` workflow is **disabled** in this repository because:

- **This is the main infrastructure platform repository** - it contains templates and source code
- **It is NOT meant for end-user deployment** - that happens in the separate `ai-infrastructure-end-user` repository
- **End-users should clone the end-user repo** and run `setup.sh` to deploy their infrastructure

## Workflow Status

- ✅ **Security Protection** - git-secrets and Husky pre-commit hooks provide comprehensive security
- ❌ **Deploy Workflow** - Disabled (renamed to `deploy.yml.disabled`)

## For End-Users

To deploy infrastructure:
1. Clone the `ai-infrastructure-end-user` repository
2. Run `setup.sh` to generate your configuration
3. Use GitHub Actions "Deploy AI Infrastructure" workflow manually
4. Choose your action: validate-only, plan, deploy, or destroy

## For Developers

To modify the deployment workflow:
1. Edit the workflow in the `ai-infrastructure-end-user` repository
2. Test changes there
3. Copy working changes back to this main repository if needed
