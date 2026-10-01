# envs/prod.tfvars - PROD-SHAPED values (always one warm copy, bigger surge ceiling, no log cap)
environment    = "prod"
min_replicas   = 1
max_replicas   = 10
daily_quota_gb = -1
# Fill in your own values (or pass with -var):
# subscription_id = "00000000-0000-0000-0000-000000000000"
# owner           = "your-name"
# container_image = "ghcr.io/your-github-user-lowercase/novabank-api:latest"
# budget_email    = "you@example.com"
