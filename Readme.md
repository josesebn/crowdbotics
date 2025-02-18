# Setup a Kubernetes Cluster

### Run npm install
`npm install express`

## Docker Build the App
`docker build -t hello-world-app:latest .`
## Docker app Locally
`docker run -p 3000:3000 hello-world-app`

## Setup Commands for AKS
`choco install terraform`
`choco install azure-cli -y`
`az login`
### Set Subscription
`az account set --subscription "your-subscription-id`
### Create Service Principal for the pipeline
`az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/your-subscription-id`
Note down the appId,password,tenant and subscription from above output

## Configure Terraform
In the provider.tf file change the values for azurerm according to match above noted values
## Terraform Create AKS Cluster and Deploy App
`terraform init`
`terraform validate`
`terraform plan`
`terraform apply -auto-approve`

### Pipelines
1. Go to Github Actions:https://github.com/josesebn/crowdbotics/actions/workflows/deploy.yml
2. Now click Run Workflow and provide input varaibles `subscription_id` `client_id` `tenant_id` `client_secret`
3. Click run workflow

