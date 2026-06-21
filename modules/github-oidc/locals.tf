locals {
  subjects = [
    for repo in var.repositories : "repo:${var.github_owner}/${repo}:*"
  ]
}
