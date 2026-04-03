locals {
  network  = data.terraform_remote_state.network.outputs
  stateful = data.terraform_remote_state.stateful.outputs
}
