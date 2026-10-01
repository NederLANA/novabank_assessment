# Demo runbook (run in GitHub Codespaces)

Prerequisites: Azure free account, empty public GitHub repo containing this folder, Codespaces open.
Install tools if missing: Azure CLI (`az`), Terraform (>= 1.6), `python3`.

## 0. Log in and prepare Azure (once)
```bash
az login --use-device-code
az account show --query "{name:name,id:id}" -o table      # note the subscription id
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
for p in Microsoft.App Microsoft.OperationalInsights Microsoft.DBforPostgreSQL Microsoft.PolicyInsights Microsoft.Consumption; do az provider register -n $p; done
```

## 1. Build the image (GitHub does it)
Push to `main`. Wait for the Action `build-image` to finish. Then make the package **public**
(Profile -> Packages -> novabank-api -> Package settings -> Change visibility).
Image name: `ghcr.io/<your-github-user-in-lowercase>/novabank-api:latest`.

## 2. Deploy DEV
```bash
cd iac
terraform init
terraform workspace new dev
terraform plan -var-file=envs/dev.tfvars -out=tfplan \
  -var subscription_id=$ARM_SUBSCRIPTION_ID -var owner="<your name>" \
  -var container_image="ghcr.io/<user>/novabank-api:latest"
terraform apply tfplan
```

## 3. Validate (collect evidence for the summary)
```bash
URL=$(terraform output -raw api_url)
curl -s $URL/health
curl -s $URL/api/cards | head -c 400          # first call: source=database, then source=cache
az monitor log-analytics query -w $(az monitor log-analytics workspace show -g $(terraform output -raw resource_group) -n $(terraform output -raw log_workspace) --query customerId -o tsv) \
  --analytics-query "ContainerAppConsoleLogs_CL | take 5" -o table
az policy state list -g $(terraform output -raw resource_group) --query "[?complianceState=='NonCompliant'].resourceId" -o tsv
```
Surge demo (shows autoscale):
```bash
sudo apt-get install -y apache2-utils
ab -n 3000 -c 60 $URL/api/cards
az containerapp replica list -g $(terraform output -raw resource_group) -n ca-novabank-dev-weu-api -o table
```
Region check (EU residency evidence): `az resource list -g <rg> --query "[].{n:name,l:location}" -o table`

## 4. AI reviewer (Step 6)
```bash
terraform show -json tfplan > ../plan.json
python3 ../ai/plan_to_context.py ../plan.json > ../ai/plan_context.json
```
Then follow `ai/prompts/iac-review-clear.md`.

## 5. PROD (brief) and cleanup
```bash
terraform workspace new prod
terraform plan -var-file=envs/prod.tfvars -out=tfplan-prod -var subscription_id=$ARM_SUBSCRIPTION_ID -var owner="<your name>" -var container_image="ghcr.io/<user>/novabank-api:latest"
terraform apply tfplan-prod      # validate quickly, capture evidence, then destroy
terraform destroy -var-file=envs/prod.tfvars -var subscription_id=$ARM_SUBSCRIPTION_ID -var owner="x" -var container_image="x"
```
Cost control: destroy prod right after validation. Keep dev only if you want a live demo; destroy after the meeting.
Do not upgrade the Azure account to pay-as-you-go.

## Troubleshooting
See `iac/README.md`. Common: region restriction for PostgreSQL (change `location`), image not public (revision fails to start),
provider not registered (re-run step 0).
