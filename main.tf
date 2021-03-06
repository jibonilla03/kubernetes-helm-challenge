resource "google_service_account" "default" {
  account_id   = "gketestaccountid"
  display_name = "GKE service account"
}

# Ensures that the Google Cloud Storage bucket that backs Google Container Registry exists. 
resource "google_container_registry" "registry" {
  project  = "quickstart-with-helm-030321"
  location = "US"
}

resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_container_registry.registry.id
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.default.email}"
}

# Add a repository for storing artifacts. This resource is in beta, and should be used with the terraform-provider-google-beta provider. 
resource "google_artifact_registry_repository" "my-repo" {
  provider = google-beta

  location = "us-east1"
  repository_id = "hello-helm-repo"
  description = "Helm repository"
  format = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "test-iam" {
  provider = google-beta

  location = google_artifact_registry_repository.my-repo.location
  repository = google_artifact_registry_repository.my-repo.name
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.default.email}"
}


resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "us-east1" # Autopilot - Optimized Kubernetes cluster with a hands-off experience and pay-per-pod. 

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

# Manages a node pool in a Google Kubernetes Engine (GKE) cluster separately from the cluster control plane.
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-east1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

output "service_account_email" {
  value = google_service_account.default.email
}