<!---
Author: Sudhara Dharmawardhana
Project Name: Azure Labs
-->

# Azure Labs

![network diagram](./Repo_Artefacts/Azure_Lab.svg)

## What is this project?

- The objective of this project is to quickly deploy a virtual machine in Azure using Infrastructure as Code (IaC).
- This project uses the Azure DevOps pipeline to deploy Windows and Linux virtual machines in Azure.
- The current code deploys one Windows machine and one Linux machine. A change in code can help deploy the desired number of machines.
- The project uses Azure Key Vault to store the credentials and a Log Analytics Workspace to collect the VM logs.
- On Linux machines, ports 80 to 8443 will be opened to the internet. However, allow-listed IPs can access all the ports.
- On Windows machines, ports 80 and 8080 will be opened to the internet. However, allow-listed IPs can access all the ports.
- These port restrictions can be changed easily by editing the "Network Security Group" section under each VM.

## How to use this project?

This information is as of May 2024.

#### **1. Create a Resource Group in Azure**
- This [article](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal) will guide you through creating a Resource Group. 
- Copy the name of the Resource Group. You must submit this as a variable at a later stage.

#### **2. Create a Key Vault inside the Resource Group**
- This [article](https://learn.microsoft.com/en-us/azure/key-vault/general/quick-create-portal) will guide you through creating a Key Vault. 
- Copy the name of the Key Vault. You must submit this as a variable at a later stage.

#### **3. Create a Storage Account inside the Resource Group**
- This [article](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) will guide you through creating a Key Vault.
- Create a container inside the storage account.
- Copy the name of the storage account. You must submit this as a variable at a later stage.
- Copy the name of the container. You must submit this as a variable at a later stage.

#### **4. Create an Azure DevOps Repository and Connect it to the Resource Group**
- This [article](https://learn.microsoft.com/en-us/azure/devops/repos/git/create-new-repo?view=azure-devops) will guide you through creating a git repository in Azure DevOps.
- Go to project settings.
- Go to service connections and create a service connection. This [article](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) will guide you.
    - Choose Azure Resource Manager
    - Choose Workload Identity Federation
    - Use subscription
    - Choose the created resource group
    - "Grant access permission to all pipelines" is not required.
    - Copy the name of the connection (backend service connection). You must submit this as a variable at a later stage.

#### **5. Assign correct permissions to the PipeLine Service Principal and Your Main Account within Resource Group and Key Vault**
- Go to the Azure Portal. Then go to Microsoft Entra ID. Then visit App Registration. Then go to All Applications and identify the app registration that is connected to the Azure Repository you created in the above step.
- Copy the name of the app registration. You will need it at a later stage.
- Go to the Key Vault you created and go to Access Control.
- Using Add Role Assignment, grant "Key Vault Secrets User" access to the application you created under app registration.
- Again, using Add Role Assignment, grant "Key Vault Administrator" access to your account.

#### **6. Create the username and the password for server admin account in Key Vault**
- Go to the Key Vault. Then go to Secrets and add two secrets. The first one should be the username. The second one should be the password. All machines will use this username and password for the admin account. You can later change it using a method, such as an Ansible script. Copy the name of each secret name you created.

#### **7. Create and Run the Pipeline**

- If you do not have the Terraform extension connected to Azure DevOps, you will have to install it first using DevOps Organisation Settings.

**Create the pipeline**
- Upload the repository into Azure Repository you created.
- Go to Pipelines and Create a Pipeline.
    - Select the Repository.
    - Select "Existing Azure Piplines YAML file" and select the "azure-devops-pipeline" YAML file that is in the repository.
    - Click save (under Run). Then go back to Pipelines and change the name.
    - Do not run the pipeline.

**Run the pipeline**
- Create a branch.
- Update the values in the "vars_az.yml" and "vars_tf.yml" files. Then push the updates to the newly created branch.
- Go to pipelines.
- Run the pipeline. Make sure to choose the correct branch. You will have to manually permit the pipeline if this is the first run.

#### Other information

**Virtual machine & extension information**

- Authenticate first: `az login`
- Use this command to identify the latest linux azure monitor version: `az vm extension image list --location australiaeast --name AzureMonitorLinuxAgent --output table`
- Use this command to identify the latest linux image version and its offer: `az vm image list --publisher Canonical --output table`
- Use this command to identify the latest windows azure monitor version: `az vm extension image list --location australiaeast -o table --name AzureMonitorWindowsAgent`
- Use this command to identify the latest linux image version and its offer: `az vm image list --publisher windows --output table`