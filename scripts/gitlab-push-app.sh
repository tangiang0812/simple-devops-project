#!/bin/bash

git -C "$(git rev-parse --show-toplevel)" subtree push \
  --prefix=app \
  https://root:${TF_VAR_gitlab_root_password}@gitlab.gnaig.click/root/ops-inspiration-console.git \
  release

git -C "$(git rev-parse --show-toplevel)" subtree push \
  --prefix=manifest \
  https://root:${TF_VAR_gitlab_root_password}@gitlab.gnaig.click/root/ops-inspiration-console-manifest.git \
  release
