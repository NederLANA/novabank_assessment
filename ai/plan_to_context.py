"""Turns a Terraform plan (JSON) into a SMALL, SAFE summary you can give to an AI reviewer.
Usage:  terraform show -json tfplan > plan.json
        python3 ai/plan_to_context.py plan.json > ai/plan_context.json
Safety: drops anything that looks like a secret; keeps only review-relevant settings.
SAY: "I never give the AI the state file or secrets - only a sanitised list of resources and settings."
"""
import json
import sys

SECRET_WORDS = ("password", "secret", "token", "key", "connection_string")
KEEP_WORDS = (
    "location", "tags", "sku", "retention", "public_network", "external_enabled",
    "backup", "geo_redundant", "replicas", "version", "allow_insecure", "high_availability",
)


def flatten(value, prefix=""):
    out = {}
    if isinstance(value, dict):
        for k, v in value.items():
            out.update(flatten(v, f"{prefix}{k}."))
    elif isinstance(value, list):
        for i, v in enumerate(value):
            out.update(flatten(v, f"{prefix}{i}."))
    else:
        out[prefix.rstrip(".")] = value
    return out


def main(path):
    plan = json.load(open(path))
    resources = []
    for rc in plan.get("resource_changes", []):
        after = (rc.get("change") or {}).get("after") or {}
        flat = flatten(after)
        kept = {
            k: v for k, v in flat.items()
            if any(w in k.lower() for w in KEEP_WORDS)
            and not any(s in k.lower() for s in SECRET_WORDS)
            and v not in (None, "", [], {})
        }
        resources.append({"address": rc["address"], "type": rc["type"],
                          "actions": rc["change"]["actions"], "settings": kept})
    print(json.dumps({"resource_count": len(resources), "resources": resources}, indent=2))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: plan_to_context.py plan.json")
    main(sys.argv[1])
