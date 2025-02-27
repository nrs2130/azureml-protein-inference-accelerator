# Azure ML Protein Inference Accelerator

This repository provides an **out-of-the-box** solution for deploying an Azure Machine Learning environment to run large-scale protein inference workloads (e.g., [AlphaFold](https://github.com/deepmind/alphafold) and [RoseTTAFold](https://github.com/RosettaCommons/RoseTTAFold)) on Azure.

It covers:
- **Infrastructure-as-Code (Bicep)** templates to provision your Azure ML workspace, compute, and networking.
- **CI/CD with GitHub Actions** or **manual CLI** deployment paths.
- **Pre-built ML pipelines** for AlphaFold and RoseTTAFold inference.
- **Security & RBAC** (Admin, Data Scientist, Reader roles).
- **Monitoring** and **Logging** via Azure Monitor/Log Analytics.
- **Cleanup** script to tear down all resources when done.

---

## 1. Prerequisites

1. **Azure Subscription**  
   - You need an Azure subscription with permissions to create resources (e.g., Contributor or Owner role at the subscription or resource group level).

2. **Azure CLI** (if deploying manually)  
   - Install the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli).  
   - Ensure you can run `az login` and have access to your subscription.

3. **GitHub Account** (if using GitHub Actions)  
   - If you plan to deploy using CI/CD, you’ll need a GitHub account and a repository (fork or create your own).  
   - Set up a [Service Principal or OpenID Connect credentials](https://github.com/azure/login#configure-a-service-principal-with-a-secret) for GitHub Actions to authenticate to Azure.

4. **(Optional) GitHub CLI**  
   - If you want to automate creation of your own GitHub repo from this template, install the [GitHub CLI](https://cli.github.com/). Otherwise, you can just fork this repo manually.

5. **Sufficient Azure Quotas**  
   - Ensure you have enough quota for CPU/GPU cores in your chosen region (especially if you plan to run GPU-heavy inference).

---

## 2. Getting the Code

You have two main approaches:

### Option A: Fork this Repository
1. In GitHub, click **Fork** → select your GitHub account/org.
2. Clone your fork locally:
   ```bash
   git clone https://github.com/nrs2130/azureml-inference-accelerator.git
   cd azureml-inference-accelerator
