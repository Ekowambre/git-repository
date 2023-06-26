# Define the teams and add them to the repository
resource "github_team" "engineering_team" {
  name        = "engineering_team"
  description = "engineering team"
  privacy     = "closed"
}

resource "github_team_repository" "engineers_team" {
  team_id    = github_team.engineers.id
  repository = github_repository.template.name
  permission = "push"
}


resource "github_team" "codeowners" {
  name        = "codeowners"
  description = "Mandatory approver team for pull requests"
  privacy     = "closed"
}

resource "github_team_repository" "codeowners_team" {
  team_id    = github_team.codeowners.id
  repository = github_repository.template.name
  permission = "pull"
}


resource "github_team" "architects" {
  name        = "architects"
  description = "Architects team"
  privacy     = "closed"
}

resource "github_team_repository" "architects_team" {
  team_id    = github_team.architects.id
  repository = github_repository.template.name
  permission = "pull"
}


/*resource "github_team_repository" "engineering_team_repo" {
  team_id    = github_team.engineering_team.id
  branch_id  = github_branch.main.id
  repository = github_repository.template.name
  permission = ["push", "pull"]
}
*/

# Define a pull request template and enforce it
resource "github_repository_pull_request_template" "my_template" {
  repository = github_repository.template.name
  template   = <<-EOF
## What does this PR do?
- 
## What are the relevant tickets?
- 
## Screenshots (if applicable)
-
## Notes for Reviewers
-
  EOF
}

resource "github_repository_pull_request_review" "codeowners_review" {
  repository                      = github_repository.template.name
  dismiss_stale_reviews           = true
  require_code_owner_reviews      = true
  required_approving_review_count = 1
}


