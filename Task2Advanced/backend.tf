terraform {
  backend "s3" {
    bucket         = "future20-tfstate-b1g*********"
    key            = "terraform.tfstate"
    region         = "ru-central1"
    use_lockfile   = true
    use_path_style = false

    # non-default workspace: состояние пишется в envs/<workspace>/terraform.tfstate
    workspace_key_prefix = "envs"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
  }
}
