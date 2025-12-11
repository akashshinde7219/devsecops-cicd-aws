terraform {
  backend "s3" {
    bucket         = "devsecops-cicd-project01"
    key            = "devsecops-cicd/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile = true
    encrypt        = true
  }
}
