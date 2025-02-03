#!/bin/bash

# Récupérer les informations ACR depuis Terraform
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
ACR_USERNAME=$(terraform output -raw acr_username)
ACR_PASSWORD=$(terraform output -raw acr_password)

# Se connecter à ACR
echo $ACR_PASSWORD | docker login $ACR_LOGIN_SERVER -u $ACR_USERNAME --password-stdin

# Construire l'image
docker build -t $ACR_LOGIN_SERVER/laravel-app:latest .

# Pousser l'image
docker push $ACR_LOGIN_SERVER/laravel-app:latest 