#!/bin/bash

helm version --short

eksctl utils associate-iam-oidc-provider \
  --region ${AWS_REGION} \
  --cluster eksgdbclu \
  --approve

curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/install/iam_policy.json
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
  --cluster eksgdbclu \
  --namespace kube-system \
  --region $AWS_REGION \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
if [[ $? -ne 0 ]]; then
 echo "failed to setup service acccount, pls fix and retry"
 exit 1
fi

kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master

kubectl get crd

helm repo add eks https://aws.github.io/eks-charts

helm upgrade -i aws-load-balancer-controller \
    eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=eksgdbclu \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.tag="v2.3.0"

kubectl -n kube-system rollout status deployment aws-load-balancer-controller

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml
sleep 30
kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'


