# a2-gcp-terraform
Terraform for launching Chef Automate on GCE

## Launch A2 on GCE
Populate terraform values in terraform/variables.tf
* project - This is the GCP project in which to launch the instance.
* region - This is GCP region in which your instance will run
* gcp-key-file - This is the key file containing your gcp credentials. (Must have launch vm instance permissions)
* automate-license - This is the licence key of your automate instance

From Terraform directory
* Run `terraform init` 
* Run `terraform apply`
