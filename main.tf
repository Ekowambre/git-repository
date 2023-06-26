# Creating the provider
provider "github" {
  token = "<token>"
}

# Provisioning the github repo
resource "github_repository" "template" {
  name        = "template"
  description = "My awesome codebase"
  auto_init   = true
}

# Creating a branch called Develpoment
resource "github_branch" "development" {
  repository = github_repository.template.name
  branch     = "development"
}

# Resource to make the development branch the default branch
resource "github_branch_default" "default" {
  repository = github_repository.template.name
  branch     = github_branch.development.branch
}

# Creating the main branch 
resource "github_branch" "main" {
  repository = github_repository.template.name
  branch     = "main"
}


# Creating the feature branch 
resource "github_branch" "feature" {
  repository = github_repository.template.name
  branch     = "feature"
}

# Enable branch protection on the development branch
resource "github_branch_protection" "development_protection" {
  repository_id                   = github_repository.template.id
  branch                          = github_branch.development.branch
  dismiss_stale_reviews           = true
  require_code_owner_reviews      = true
  required_approving_review_count = 1
}



# Resource block for the pull request
resource "github_repository_pull_request" "template-pull-request" {
  base_repository = "template"
  base_ref        = "development"
  head_ref        = "feature-branch"
  title           = "My newest feature"
  body            = "This will change everything"
}





