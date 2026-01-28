# Patterns Lab

---
**Pre-commit hook**:
To keep a consistent style, use the Makefile (via your IDE or CLI) when setting up or working with the repository.

Install the hooks (including commit-msg):

```bash
pre-commit install
pre-commit install --hook-type commit-msg
```

---

### Terraform Command Workflow

Before run:

```bash
aws sts get-caller-identity # check identity configureation 
aws configure # if you are not authorized in AWS
```

**Develop**

- `terraform init -backend-config=environments/develop.backend.hcl`
- `export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, etc.`
- `terraform plan  -var-file=environments/develop.tfvars`
- `terraform apply -var-file=environments/develop.tfvars -auto-approve && terraform output -json > develop-outputs.json`
- `terraform destroy -var-file=environments/develop.tfvars`

**Production**

- `terraform init -backend-config=environments/production.backend.hcl`
- `export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, etc.`
- `terraform plan  -var-file=environments/production.tfvars`
-
`terraform apply -var-file=environments/production.tfvars -auto-approve && terraform output -json > production-outputs.json`
- `terraform destroy -var-file=environments/production.tfvars`

---

### Docker manual commands run

```bash
docker build -f docker/Dockerfile -t demo:local .

docker run -d --name demo --restart unless-stopped -p 8080:8080 \
  -e JAVA_OPTS="-Xms128m -Xmx256m" demo:local
```

### Workflow variables and secrets

For the main branch uses `develop` environments secrets:

| KEY                   | TYPE     |
|-----------------------|----------|
| AWS_SECRET_ACCESS_KEY | secret   |
| AWS_ACCESS_KEY_ID     | secret   |
| AWS_ACCOUNT_ID        | variable |
| AWS_REGION            | variable |
| ECR_REPOSITORY_URL    | variable |
| ECS_CLUSTER_NAME      | variable |
| ECS_SERVICE_NAME      | variable |
| ECS_CONTAINER_NAME    | variable |
| NEW_RELIC_APP_NAME    | variable |
| NEW_RELIC_LICENSE_KEY | secret   |

Production deployments require a GitHub Actions environment named `production`
with the same variables/secrets and manual approval enabled (Environment protection rules).
