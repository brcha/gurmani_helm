#!/usr/bin/env bash
# Wrapper script to use local .kube/config with kubectl
kubectl --kubeconfig .kube/config "$@"
