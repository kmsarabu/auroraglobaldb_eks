#!/bin/bash

curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

helm version --short
if [[ $? -ne 0 ]]; then
 echo "Helm not installed, please fix and retry"
 exit 1
fi

helm repo add stable https://charts.helm.sh/stable

helm search repo stable

helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
source <(helm completion bash)

