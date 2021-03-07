# Deploying a containerized web application on GKE using Terraform, K8s and Helmfile.
Manage Kubernetes with Helmfile

## Objectives
	• Obtain Docker image to push.
	• Upload the Docker image to Container Registry.
	• Create a GKE cluster using Terraform.
    • Create a repository in Artifact Registry with Terraform.
    • Authenticate with the Artifact Registry repository using Docker configuration.
	• Deploy the sample app to the cluster using kubectl.
	• Manage autoscaling for the deployment.
	• Expose the sample app to the internet.
	• Deploy a new version of the sample app.
	• Create a sample chart.
	• Push the chart to the repository.
	• Pull the chart from the repository.
    • Deploy the chart with Helmfile.

## Before you begin
Take the following steps to enable the Kubernetes Engine API: 
	1. Visit the Kubernetes Engine page in the Google Cloud Console. 
	2. Create or select a project. 
	3. Wait for the API and related services to be enabled. This can take several minutes. 
	4. Make sure that billing is enabled for your Cloud project.

## Use command-line tools locally
	• Install the Cloud SDK, which includes the gcloud command-line tool.
	• Using the gcloud command line tool, install the Kubernetes command-line tool. kubectl is used to communicate with Kubernetes, which is the cluster orchestration system of GKE    clusters:
    
    ```bash
		gcloud components install kubectl
    ```
	• Install Helm 3 if it is not already installed.
	Enable Helm experimental support for OCI images with the HELM_EXPERIMENTAL_OCI variable. Add the following line to ~/.bashrc (or ~/.bash_profile in macOS, or wherever your shell stores environment variables):
    
    ```console
		export HELM_EXPERIMENTAL_OCI=1
    ```
	• Run the following command to load your updated .bashrc (or .bash_profile) file:
    
    ```console
		source ~/.bashrc
    ```
	• Install Helm File - https://github.com/roboll/helmfile#installation
		download one of releases
    ```console 
        wget -O helmfile https://github.com/roboll/helmfile/releases/download/v0.138.6/helmfile_linux_amd64
    ```
