terraform {
  backend "local" {
    # TODO: replace with remote backend when state service is selected.
    path = "terraform.tfstate"
  }
}
