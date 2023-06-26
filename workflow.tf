# Define a workflow for Terraform
resource "github_actions_workflow" "terraform" {
  name     = "Terraform Workflow"
  on       = "push"
  resolves = ["terraform-apply"]
}

# Define jobs for the workflow
jobs = {
  "terraform-validate" : {
    name    = "Terraform Validate"
    runs-on = "ubuntu-latest"

    steps = [
      {
        name = "Checkout"
        uses = "actions/checkout@v2"
      },
      {
        name = "Terraform Init"
        run  = "terraform init"
      },
      {
        name = "Terraform Validate"
        run  = "terraform validate -check-variables=false"
      },
      {
        name = "TFlint"
        uses = "terraform-linters/tflint-action@v1"
        with = {
          args = "--deep"
        }
      }
    ]
  },
  "terraform-plan" : {
    name    = "Terraform Plan"
    runs-on = "ubuntu-latest"
    needs   = "terraform-validate"
    steps = [
      {
        name = "Checkout"
        uses = "actions/checkout@v2"
      },
      {
        name = "Terraform Init"
        run  = "terraform init"
      },
      {
        name = "Terraform Plan"
        run  = "terraform plan"
      }
    ]
  },
  "terraform-apply" : {
    name    = "Terraform Apply"
    runs-on = "ubuntu-latest"
    needs   = "terraform-plan"

    steps = [
      {
        name = "Checkout"
        uses = "actions/checkout@v2"
      },
      {
        name = "Terraform Init"
        run  = "terraform init"
      },
      {
        name = "Terraform Apply"
        run  = "terraform apply -auto-approve"
      }
    ]
  }
}



#Define branch protection rules

branch_protection = {
  development = {
    pattern        = "development"
    enforce_admins = true
    required_status_checks = {
      strict = true
      contexts = [
        "default"
      ]
    }
    required_pull_request_reviews = {
      required_approving_review_count = 1
      dismiss_stale_reviews           = true
    }
    restrictions = null
  },
  main = {
    pattern        = "main"
    enforce_admins = true
    required_status_checks = {
      strict = true
      contexts = [
        "default"
      ]
    }
    required_pull_request_reviews = {
      required_approving_review_count = 1
      dismiss_stale_reviews           = true
    }
    restrictions = null
  }
}

#Create GitHub Secrets

lifecycle {
  ignore_changes = [
    github_repository.template.name
  ]
}

resource "github_actions_secret" "aws_credentials" {
  repository      = github_repository.template.name
  secret_key     = "AWS_CREDENTIALS"
  secret_access_key = ""
  plaintext_value = "my-secret-value"
}


#Create Teams and add them to the repository
resource "github_team" "codeowners" {
  name    = "Code Owners"
  privacy = "closed"
}

resource "github_team_repository" "codeowners_repo" {
  team_id    = github_team.codeowners.id
  repository = github_repository.template.name
  permission = "pull"
}

resource "github_team" "engineers" {
  name    = "Engineers"
  privacy = "closed"
}

resource "github_team_repository" "engineers_repo" {
  team_id    = github_team.engineers.id
  repository = github_repository.template.name
  permission = "push"
}

resource "github_team" "architects" {
  name    = "Architects"
  privacy = "closed"
}

resource "github_team_repository" "architects_repo" {
  team_id    = github_team.architects.id
  repository = github_repository.template.name
  permission = "push"
}

resource "github_branch_protection" "development_branch_protection" {
  repository = github_repository.template.name
  branch     = "development"

  # Require pull request reviews before merging
  required_pull_request_reviews {
    # Require at least one review
    required_approving_review_count = 1

    # Dismiss stale pull request approvals automatically
    dismiss_stale_reviews = true

    # Require review from CodeOwners team
    dismissal_restrictions {
      teams {
        slug = github_team.codeowners.slug
      }
    }
  }

  # Restrict who can push to this branch
  #enforce_admins = true

  # Require status checks to pass before merging
  required_status_checks {
    strict = true
  }
}
