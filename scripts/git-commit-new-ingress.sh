#!/bin/bash

git -C "$(git rev-parse --show-toplevel)" add ./manifest/app/ingress.yaml
git -C "$(git rev-parse --show-toplevel)" commit -m "auto(manifest): auto update app ingress"
