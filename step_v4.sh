#!/bin/bash

vpcid=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

rm -f eksauroragdb.yaml

cat << EOF > eksauroragdb.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: eksgdbclu
  region: ${AWS_REGION}
  version: "1.21"
vpc:
  id: ${vpcid}
  subnets:
    private:
EOF

aws ec2 describe-subnets --filters Name=vpc-id,Values=${vpcid} --query 'Subnets[?(! MapPublicIpOnLaunch)].{AvailabilityZoneId:AvailabilityZoneId,SubnetId:SubnetId}' --output text | while read az subnet
do
 echo "       ${az}: { id: ${subnet} }" >> eksauroragdb.yaml
done

cat <<EOF >> eksauroragdb.yaml
managedNodeGroups:
  - name: eksgdb-1-workers
    minSize: 2
    maxSize: 3
    desiredCapacity: 2
    instanceType: t3.large
    labels: {role: worker}
    privateNetworking: true
    ssh:
      enableSsm: true
    tags:
      nodegroup-role: worker
    iam:
      withAddonPolicies:
        externalDNS: true
        certManager: true
        albIngress: true
secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF

keyid=$AWS_ACCESS_KEY_ID
skey=$AWS_SECRET_ACCESS_KEY
defreg=$AWS_DEFAULT_REGION

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION

eksctl create cluster -f eksauroragdb.yaml

kubectl get nodes
if [[ $? -ne 0 ]]; then
 echo Error in listing nodes, pls check
 exit 1
fi

STACK_NAME=$(eksctl get nodegroup --cluster eksgdbclu -o json | jq -r '.[].StackName')
ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile

c9builder=$(aws cloud9 describe-environment-memberships --environment-id=$C9_PID | jq -r '.memberships[].userArn')
if echo ${c9builder} | grep -q user; then
	rolearn=${c9builder}
        echo Role ARN: ${rolearn}
elif echo ${c9builder} | grep -q assumed-role; then
        assumedrolename=$(echo ${c9builder} | awk -F/ '{print $(NF-1)}')
        rolearn=$(aws iam get-role --role-name ${assumedrolename} --query Role.Arn --output text) 
        echo Role ARN: ${rolearn}
fi

eksctl create iamidentitymapping --cluster eksgdbclu --arn ${rolearn} --group system:masters --username admin

export AWS_ACCESS_KEY_ID=$keyid
export AWS_SECRET_ACCESS_KEY=$skey
export AWS_DEFAULT_REGION=$defreg

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.1/components.yaml
kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'

# we need the ASG name
export ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='eksgdbclu']].AutoScalingGroupName" --output text)

# increase max capacity up to 4
aws autoscaling \
    update-auto-scaling-group \
    --auto-scaling-group-name ${ASG_NAME} \
    --min-size 2 \
    --desired-capacity 2 \
    --max-size 4

# Check new values
aws autoscaling \
    describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='eksgdbclu']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table

eksctl utils associate-iam-oidc-provider \
    --cluster eksgdbclu \
    --approve

mkdir ~/environment/cluster-autoscaler

cat <<EoF > ~/environment/cluster-autoscaler/k8s-asg-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EoF

aws iam create-policy   \
  --policy-name k8s-asg-policy \
  --policy-document file://~/environment/cluster-autoscaler/k8s-asg-policy.json

ACCOUNT_ID=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.accountId')

eksctl create iamserviceaccount \
    --name cluster-autoscaler \
    --namespace kube-system \
    --cluster eksgdbclu \
    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy" \
    --approve \
    --override-existing-serviceaccounts

kubectl -n kube-system describe sa cluster-autoscaler

kubectl apply -f https://www.eksworkshop.com/beginner/080_scaling/deploy_ca.files/cluster-autoscaler-autodiscover.yaml

# we need to retrieve the latest docker image available for our EKS version
export K8S_VERSION=$(kubectl version --short | grep 'Server Version:' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -d. -f1,2)
export AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})

kubectl -n kube-system \
    set image deployment.apps/cluster-autoscaler \
    cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v${AUTOSCALER_VERSION}

#kubectl -n kube-system logs -f deployment/cluster-autoscaler

