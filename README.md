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
    
		gcloud components install kubectl

	• Install Helm 3 if it is not already installed.
	Enable Helm experimental support for OCI images with the HELM_EXPERIMENTAL_OCI variable. Add the following line to ~/.bashrc (or ~/.bash_profile in macOS, or wherever your shell stores environment variables):
    
		export HELM_EXPERIMENTAL_OCI=1

	• Run the following command to load your updated .bashrc (or .bash_profile) file:
    
		source ~/.bashrc

	• Install Helm File - https://github.com/roboll/helmfile#installation
		download one of releases
     
        wget -O helmfile https://github.com/roboll/helmfile/releases/download/v0.138.6/helmfile_linux_amd64
    
    • For Ubuntu (Linux) first move it to the /usr/local/bin folder and change the permissions:
		 
         sudo cp ./helmfile /usr/local/bin
		 sudo chmod +x /usr/local/bin/helmfile
		
    • After that you should be able to run the command:

         helmfile --version

	• Install Docker Community Edition (CE) on your workstation. You use this to build a container image for the application.
    • Install the Git source control tool to public solution to  GitHub.

## Create a Docker repository
### Obtain an image to push
For this, you will push a sample image named nginxdemos/hello.
	• Change to a directory where you want to save the image.
	• Run the following command to pull latest version of the image.

        docker pull nginxdemos/hello

### Pushing the Docker image to Container Registry
You must upload the container image to a registry so that your GKE cluster can download and run the container image. In Google Cloud, Container Registry is available by default. 
	• Set the PROJECT_ID environment variable to your Google Cloud project ID (project-id). The PROJECT_ID variable associates the container image with your project's Container Registry.
		
        export PROJECT_ID=project-id

	• Tag the Docker image for hello-app:

        docker tag nginxdemos/hello:latest gcr.io/${PROJECT_ID}/hello-app:v1

    • Run the docker images command to verify that the tag was created:
		
        docker images

	• Enable the Container Registry API for the Google Cloud project you are working on: 

		gcloud services enable containerregistry.googleapis.com

	• Configure the Docker command-line tool to authenticate to Container Registry:

		gcloud auth configure-docker

	• Login to Docker Registry

		docker login gcr.io/${PROJECT_ID}

	• Push the Docker image that you just built to Container Registry: 

		docker push gcr.io/${PROJECT_ID}/hello-app:v1

### Running your container locally (optional)
	• Test your container image using your local Docker engine:
		
        docker run --rm -p 8080:80 gcr.io/${PROJECT_ID}/hello-app:v1

	• Open a new terminal window (or a Cloud Shell tab) and run the following command to verify that the container works and responds to requests with "Hello, World!":

		curl http://localhost:8080

	After you've seen a successful response, you can shut down the container by pressing Ctrl+C in the tab where the docker run command is running.

## Creating a GKE cluster
Now that the Docker image is stored in Container Registry, create a GKE cluster to run hello-app. A GKE cluster consists of a pool of Compute Engine VM instances running Kubernetes, the open source cluster orchestration system that powers GKE.

	• Set your project ID option for the gcloud tool:

		gcloud config set project $PROJECT_ID

	• Set your zone or region. Depending on the mode of operation that you choose to use in GKE, specify a default zone or region. If you use the Standard mode, your cluster is zonal , so set your default compute zone. If you use the Autopilot mode, your cluster is regional, so set your default compute region. Choose the zone or region that is closest to you.
		
        terraform apply 

    It takes a few minutes for your GKE cluster to be created and health-checked.

	• After the command completes, run the following command to see the cluster's three worker VM instances:
		
        gcloud compute instances list
		
	• Get the cluster credentials so that kubectl can access the cluster:

		gcloud container clusters get-credentials --zone us-east1 my-gke-cluster

### Configuring access control to Container registry (Managed by Terraform)
	• No need for performing the below steps since Terraform configuration takes care of it.
	• Click the link artifacts.PROJECT_ID.appspot.com or STORAGE-REGION.artifacts.PROJECT_ID.appspot.com for the bucket.
	• Select the Permissions tab, Click Add.
	•  In the Members field, enter the email addresses of accounts that require access, separated by commas. This email address can be one of the following:
	• From the Select a role drop-down menu, select the Cloud Storage category, and then select the appropriate permission.
		Storage Object Viewer to pull images only
		Storage Object Admin to push and pull images
    • Click Add.

### Deploying the sample app to GKE (optional)
	• Create a Kubernetes Deployment for your hello-app Docker image.

		kubectl create deployment hello-app --image=gcr.io/${PROJECT_ID}/hello-app:v1

	• Set the baseline number of Deployment replicas to 3.
		
        kubectl scale deployment hello-app --replicas=3
		
	• To see the Pods created, run the following command:
        
        kubectl get pods

### Exposing the sample app to the internet (optional)
	• Use the kubectl expose command to generate a Kubernetes Service for the hello-app deployment.

		kubectl expose deployment hello-app --name=hello-app-service --type=LoadBalancer --port 80 --target-port 80
				
	Here, the --port flag specifies the port number configured on the Load Balancer, and the --target-port flag specifies the port number that the hello-app container is listening on.
	• Run the following command to get the Service details for hello-app-service.
		
        kubectl get service
		
	• Copy the EXTERNAL_IP address to the clipboard 

### Cleaning up
	• Delete the Service: This deallocates the Cloud Load Balancer created for your Service:
		
        kubectl delete service hello-app-service
		
	• Delete the Deployment: This removes all the pods managed by the deployment:
        
        kubectl delete deplyment hello-app

## Create a artifact repository (Managed by Terraform)
Create a Docker repository to store the sample chart for this app. Note: There is no need to manually create these resources since they are fully managed by Terraform.
	• Run the following command to create a new Docker repository named quickstart-helm-repo in the location us-central1 with the description "docker repository".
		
        gcloud artifacts repositories create hello-helm-repo --repository-format=docker \
        --location=us-east1 --description="Helm repository"
		
	• Run the following command to verify that your repository was created.

		gcloud artifacts repositories list

### Create a chart
	• Change to a directory where you want to create the chart.
	• Run the following command to create the chart:

		helm create hello-chart

	Helm creates a directory named hello-chart with a default set of chart files.
	
	• Save the chart as an OCI image, using the full path to the image location in the repository you created.
		
        helm chart save hello-chart us-east1-docker.pkg.dev/${PROJECT_ID}/hello-helm-repo/hello-chart
		
	• List charts in your local cache.
		
        helm chart list

### Authenticate with the repository
Before you can push or install images, Helm must authenticate to Artifact Registry.

#### Authenticate with your Docker configuration
To configure Helm to use your Docker registry settings:

	• Add the following lines to ~/.bashrc (or ~/.bash_profile in macOS, or wherever your shell stores environment variables):

		export DOCKER_CONFIG="~/.docker"

        export HELM_REGISTRY_CONFIG="${DOCKER_CONFIG}/config.json"

		DOCKER_CONFIG is the Docker environment variable for the location of the Docker client configuration file, config.json. The default location is ~/.docker.
		HELM_REGISTRY_CONFIG is the Helm environment variable for the registry configuration file. It points to the Docker config.json file.
	• Run the following command to load your updated .bashrc (or .bash_profile) file:
		
        source ~/.bashrc

Helm is now configured to authenticate using credentials configured for your Docker client. You're ready to push the chart to the repository.

### Push the chart to Artifact Registry
After you have created your chart and authenticated to the Artifact Registry repository, you can push the chart to the repository.
    • To push the chart, run the following command:

		helm chart push us-east1-docker.pkg.dev/${PROJECT_ID}/hello-helm-repo/hello-chart:0.1.0
			
    • Run the following command to verify that the chart is now stored in the repository:
		
        gcloud artifacts docker images list us-east1-docker.pkg.dev/${PROJECT_ID}/hello-helm-repo

### Deploy the chart with Helm (optional)
In Helm, a deployed instance of your application is called a release. After you have added your repository to the Helm configuration, you can deploy a release of your chart.

    • Run the following command to deploy a release of hello-chart using the locally extracted chart files:

        helm install hello-chart ./hello-chart

### Clean up
To avoid incurring charges to your Google Cloud account for the resources used, follow these steps. 
	• We can use this command to delete a release from Kubernetes:
		
        helm delete  hello-chart
		
	• Delete the repository you created with the following command:
		
        gcloud artifacts repositories delete hello-helm-repo --location=us-east1

	• Delete the cluster you created:
		
        terrafom destroy

## Create Helm releases with HelmFile
	• Run helmfile sync command to deploy all apps (Helm releases defined in helmfile.yaml):
		
        helmfile sync

## Clean up
To avoid incurring charges to your Google Cloud account for the resources used, follow these steps. 
	• List releases defined in state file
		
        helmfile list
		
	• We can use this command to delete and then purges releases.
		
        helmfile destroy
		
	• Delete the repository you created with the following command:
		
        gcloud artifacts repositories delete hello-helm-repo --location=us-east1
		
	• Delete the cluster you created:
		
        terrafom destroy
		
	• Delete your container images: This deletes the Docker images you pushed to Container Registry.
		
        gcloud container images delete gcr.io/${PROJECT_ID}/hello-app:v1  --force-delete-tags --quiet


