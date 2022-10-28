#!/bin/bash

ACCOUNT_ID=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.accountId')
AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

helm version --short

eksctl utils associate-iam-oidc-provider \
  --region ${AWS_REGION} \
  --cluster eksgdbclu \
  --approve

curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/install/iam_policy.json
curl -o iam_policy_v1_to_v2_additional.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/install/iam_policy_v1_to_v2_additional.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerAdditionalIAMPolicy \
  --policy-document file://iam_policy_v1_to_v2_additional.json

eksctl create iamserviceaccount \
  --cluster eksgdbclu \
  --namespace kube-system \
  --region $AWS_REGION \
  --name aws-load-balancer-controller \
  --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy" \
  --override-existing-serviceaccounts \
  --approve
if [[ $? -ne 0 ]]; then
 echo "failed to setup service acccount, pls fix and retry"
 exit 1
fi

myrole=$(eksctl get iamserviceaccount --cluster eksgdbclu --name aws-load-balancer-controller --namespace kube-system -o json | jq '.[].status.roleARN' | awk -F/ '{print $2}' |awk -F\" '{print $1}')

aws iam attach-role-policy \
  --role-name ${myrole} \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerAdditionalIAMPolicy

kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master

kubectl get crd

helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller \
    eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=eksgdbclu \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

kubectl -n kube-system rollout status deployment aws-load-balancer-controller

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.1/components.yaml
sleep 30
kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'


