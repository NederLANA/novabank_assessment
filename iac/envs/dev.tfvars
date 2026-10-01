# envs/dev.tfvars - DEV values (cheap, scales to zero)
environment    = "dev"
min_replicas   = 0
max_replicas   = 3
daily_quota_gb = 1
# Fill in your own values (or pass with -var):
# subscription_id = "00000000-0000-0000-0000-000000000000"
# owner           = "your-name"
# container_image = "ghcr.io/your-github-user-lowercase/novabank-api:latest"
# budget_email    = "you@example.com"
