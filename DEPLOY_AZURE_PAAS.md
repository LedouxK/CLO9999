# Déploiement Laravel sur Azure PaaS

## Prérequis
- Azure CLI (`az login`)
- Terraform
- GitHub Token avec permissions `repo` et `workflow`

## Fichiers requis
```
laravel/
├── terraform/
│   ├── main.tf              # Infrastructure Azure
│   ├── variables.tf         # Variables
│   ├── terraform.tfvars     # Valeurs des variables
│   ├── outputs.tf           # Outputs
│   └── mysql-firewall.tf    # Règles firewall
└── .github/
    └── workflows/
        └── deploy.yml       # Pipeline CI/CD
```

## Déploiement

1. **Variables Terraform** (`terraform.tfvars`)
```hcl
mysql_admin_password = "votre_password"
app_key             = "votre_app_key"
storage_account_key = "votre_storage_key"
web_app_name        = "laravel-app"
github_token        = "votre_github_token"
```

2. **Déployer l'infrastructure**
```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

3. **Vérifier le déploiement**
- URL App : `https://laravel-app.azurewebsites.net`
- GitHub Actions : `https://github.com/LedouxK/CLO9999/actions`

## Infrastructure créée
- App Service (PHP 8.3)
- MySQL Flexible Server
- Storage Account
- GitHub Actions Secrets

## Commandes utiles
```bash
# Voir les logs
az webapp log tail --name laravel-app --resource-group laravel-rg

# Redémarrer l'app
az webapp restart --name laravel-app --resource-group laravel-rg

# Détruire l'infrastructure
terraform destroy
``` 