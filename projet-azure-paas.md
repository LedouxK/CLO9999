# Déploiement PaaS sur Azure - Documentation du Projet

## 1. Contexte du Projet
- Application Laravel à déployer sur Azure
- Approche PaaS (Platform as a Service)
- Utilisation de Terraform pour l'Infrastructure as Code

## 2. Configuration Actuelle
### Application Laravel
- Base de données : MySQL
- Système de fichiers : Local
- Queue System : Sync
- Cache : File System
- Session Driver : File

### Stack de Monitoring
- Grafana
- Prometheus
- Loki
- Alertmanager
- Promtail

## 3. Accès Azure
### Compte Azure
- Compte fourni par l'école
- Droits limités
- Accès aux ressources suivantes :
  - Lecteur sur groupes de ressources spécifiques
  - Utilisateur DevTest Labs
  - Contributeur sur certains groupes
  - Custom DevTest Lab role

### Analyse Détaillée des Permissions
#### Groupes de Ressources Accessibles
- `t-clo-901-rns-0-items`
- `t-clo-901-rns-0`

#### Rôles et Permissions
1. **Rôles de Lecture**
   - Lecteur (Reader) sur les groupes de ressources spécifiques
   - Accès en lecture aux ressources existantes

2. **Rôles DevTest Labs**
   - Utilisateur DevTest Labs
   - Contributeur sur `microsoft.devtestlab/labs/users`
   - Custom DevTest Lab role personnalisé

#### Limitations Identifiées
- Accès principalement restreint aux environnements DevTest Labs
- Permissions de lecture sur les groupes de ressources spécifiques
- Pas de droits d'administrateur globaux
- Nécessité de travailler dans les groupes de ressources autorisés

### Stratégie de Déploiement Recommandée
1. **Utilisation Prioritaire de DevTest Labs**
   - Déploiement des ressources via DevTest Labs
   - Configuration de Terraform adaptée à l'environnement DevTest Labs

2. **Contraintes à Considérer**
   - Demande potentielle de permissions supplémentaires pour certaines ressources PaaS
   - Restriction possible sur certains services Azure
   - Nécessité de respecter les limites des groupes de ressources assignés

## 4. Besoins Infrastructure Azure
### Services Requis (à valider selon les droits)
- Azure App Service Plan & Web App
- Azure Database for MySQL
- Azure Storage Account
- Azure Key Vault
- Azure Application Insights

## 5. Prochaines Étapes
1. Vérifier les droits d'accès pour chaque service requis
2. Identifier les alternatives si certains services ne sont pas accessibles
3. Définir l'architecture finale en fonction des contraintes
4. Créer les configurations Terraform adaptées aux permissions
5. Planifier la stratégie de déploiement

## 6. Questions en Suspens
- Confirmation des droits pour créer des ressources PaaS
- Vérification des quotas disponibles
- Validation du budget disponible
- Choix du tier de service pour la base de données
- Configuration spécifique pour le monitoring dans Azure

## 7. Configuration Terraform
### Structure du Projet
```
terraform/
├── main.tf          # Configuration principale et données des ressources existantes
├── variables.tf     # Définition des variables
├── app-service.tf   # Configuration Web App
├── database.tf      # Configuration base de données
├── outputs.tf       # Définition des sorties
└── terraform.tfvars # Valeurs des variables
```

### Configuration Principale (main.tf)
- **Provider Azure** :
  - Version : ~> 3.0
  - Skip provider registration activé pour les droits limités
  
- **Ressources Existantes Utilisées** :
  - Groupe de ressources : `t-clo-901-rns-0`
  - DevTest Lab : `t-clo-901-rns-0`
  - Plan App Service : `t-clo-901-rns-0-plan`
  - MySQL Flexible Server : `t-clo-901-rns-0-mysql`

### Base de Données (database.tf)
- **Utilisation du MySQL Flexible Server Existant**
- **Nouvelle Base de Données** :
  - Nom : laravel
  - Charset : UTF8
  - Collation : utf8_unicode_ci
- **Règle de Firewall** :
  - Autorisation des services Azure

### App Service (app-service.tf)
- **Utilisation du Plan App Service Existant**
- **Nouvelle Web App** :
  - PHP 8.2
  - Configuration :
    - Always On activé
    - Variables d'environnement pour Laravel
    - Connexion à la base de données

### Ressources Créées vs Existantes
#### Ressources Existantes Utilisées
1. **Infrastructure de Base** :
   - Groupe de ressources
   - DevTest Lab
   - Réseau virtuel
   - Plan App Service
   - Serveur MySQL Flexible

#### Nouvelles Ressources Créées
1. **Application** :
   - Web App Laravel
   - Base de données sur le serveur MySQL existant
   - Règle de firewall MySQL

### Déploiement
La configuration actuelle :
1. **Utilise les Ressources Existantes** :
   - Réduit les permissions nécessaires
   - Respecte les contraintes du DevTest Lab
   - Optimise l'utilisation des ressources

2. **Crée Uniquement** :
   - Les composants applicatifs nécessaires
   - Les configurations spécifiques à Laravel

3. **Sécurité** :
   - Utilise les services managés existants
   - Configure les accès minimum nécessaires
   - Génère les secrets de manière sécurisée

### Variables (variables.tf et terraform.tfvars)
- **Location** : West Europe
- **Environnement** : dev
- **MySQL** :
  - Username : laravel_user
  - Password : Respecte les critères de sécurité Azure
    - Minimum 3 des 4 catégories suivantes :
      - Lettres majuscules
      - Lettres minuscules
      - Chiffres
      - Caractères spéciaux
    - Exemple : LaravelP@ssw0rd
- **App Service** :
  - SKU : B1 (Basic tier)

### Outputs (outputs.tf)
- URL de l'application web
- FQDN du serveur MySQL
- Nom du groupe de ressources

### Sécurité
1. **Authentification Base de Données**
   - Utilisateur administrateur personnalisé
   - Mot de passe respectant les critères de sécurité Azure
   - Accès restreint via firewall

2. **Sécurité Application**
   - TLS 1.2 minimum
   - HTTPS activé par défaut
   - Variables d'environnement sécurisées
   - APP_KEY généré aléatoirement

3. **Bonnes Pratiques**
   - Pas de secrets en clair dans le code
   - Utilisation de variables Terraform pour les informations sensibles
   - Configuration minimale mais sécurisée

### Déploiement Minimal
La configuration actuelle représente le strict minimum nécessaire pour :
1. **Application** :
   - Hébergement de l'application Laravel
   - PHP 8.2 avec configuration de base
   - Variables d'environnement essentielles

2. **Base de données** :
   - MySQL 8.0 Flexible Server
   - Configuration minimale sans backups
   - Accès sécurisé depuis l'App Service

3. **Sécurité** :
   - TLS 1.2 minimum
   - Firewall configuré
   - Accès base de données restreint

4. **Monitoring** :
   - Logs d'erreur basiques
   - Pas de configuration APM complexe

### Commandes de Déploiement
```bash
# Initialisation
terraform init

# Vérification du plan
terraform plan

# Déploiement (avec approbation requise)
terraform apply

# Pour détruire l'infrastructure
terraform destroy  # À utiliser avec précaution
```

### Notes Importantes
1. **Sécurité** :
   - Conservez les credentials en sécurité
   - Ne committez jamais terraform.tfvars
   - Sauvegardez les mots de passe de manière sécurisée

2. **Coûts** :
   - Configuration minimale pour optimiser les coûts
   - Tier Basic pour tous les services
   - Pas de ressources superflues

3. **Maintenance** :
   - Vérifiez régulièrement les logs d'erreur
   - Surveillez l'utilisation des ressources
   - Mettez à jour les mots de passe régulièrement

## 8. Processus de Déploiement
### Étapes de Déploiement
1. **Préparation** :
   - Configuration Terraform complète
   - Variables d'environnement définies
   - Droits Azure vérifiés

2. **Déploiement Initial** :
   ```bash
   # Initialisation de Terraform
   terraform init

   # Vérification du plan
   terraform plan

   # Application du plan
   terraform apply
   ```

3. **Temps de Déploiement** :
   - Durée totale estimée : 5-10 minutes
   - MySQL Flexible Server : ~5 minutes
   - App Service : ~3-5 minutes

### Vérifications Post-Déploiement
1. **Points de Terminaison** :
   - URL de l'application web (output: `app_service_url`)
   - FQDN du serveur MySQL (output: `mysql_server_fqdn`)
   - Vérifier l'accès HTTPS

2. **Base de Données** :
   - Connexion établie
   - Permissions correctes
   - Firewall configuré

3. **Application** :
   - Site web accessible
   - Pas d'erreurs dans les logs
   - Variables d'environnement correctement définies

### Gestion des Variables d'Environnement
1. **Environnement Local** :
   - Fichier `.env` utilisé pour le développement
   - Configuration Docker pour les tests locaux
   - Ne pas modifier pour le déploiement Azure

2. **Environnement Azure** :
   - Variables configurées via Terraform
   - Stockées de manière sécurisée dans App Service
   - Écrasent automatiquement la configuration locale
   - Incluent :
     ```
     APP_KEY           = Généré automatiquement
     APP_ENV           = production
     APP_DEBUG         = false
     DB_CONNECTION     = mysql
     DB_HOST          = [FQDN du serveur flexible]
     DB_PORT          = 3306
     DB_DATABASE      = laravel
     DB_USERNAME      = laravel_user
     DB_PASSWORD      = [Mot de passe sécurisé]
     ```

### Résolution des Problèmes Courants
1. **Erreurs de Déploiement** :
   - Vérifier les logs Terraform
   - Confirmer les permissions Azure
   - Valider les quotas disponibles

2. **Erreurs d'Application** :
   - Consulter les logs App Service
   - Vérifier la connexion à la base de données
   - Contrôler les variables d'environnement

3. **Problèmes de Base de Données** :
   - Vérifier les règles du firewall
   - Tester les credentials
   - Contrôler l'état du serveur MySQL

### Maintenance Continue
1. **Surveillance** :
   - Logs d'erreur App Service
   - Métriques de base de données
   - Performance de l'application

2. **Mises à Jour** :
   - Appliquer les mises à jour de sécurité
   - Maintenir les versions PHP/MySQL
   - Revoir périodiquement la configuration

3. **Sauvegardes** :
   - État Terraform (terraform.tfstate)
   - Credentials et secrets
   - Configuration personnalisée