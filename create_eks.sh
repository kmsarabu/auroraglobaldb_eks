#!/bin/sh


function create_eks_cluster()
{
    typeset -i counter
    counter=0
    echo "aws cloudformation  create-stack --stack-name ${EKS_STACK_NAME} --parameters ParameterKey=VPC,ParameterValue=${vpcid} ParameterKey=SubnetAPrivate,ParameterValue=${subnetA} ParameterKey=SubnetBPrivate,ParameterValue=${subnetB} ParameterKey=SubnetCPrivate,ParameterValue=${subnetC} --template-body file://${EKS_CFN_FILE} --capabilities CAPABILITY_IAM"
    aws cloudformation  create-stack --stack-name ${EKS_STACK_NAME} --parameters ParameterKey=VPC,ParameterValue=${vpcid} ParameterKey=SubnetAPrivate,ParameterValue=${subnetA} ParameterKey=SubnetBPrivate,ParameterValue=${subnetB} ParameterKey=SubnetCPrivate,ParameterValue=${subnetC} --template-body file://${EKS_CFN_FILE} --capabilities CAPABILITY_IAM
    sleep 60
    # Checking to make sure the cloudformation completes before continuing
    while  [ $counter -lt 100 ]
    do
        STATUS=`aws cloudformation describe-stacks --stack-name ${EKS_STACK_NAME} --query  Stacks[0].StackStatus`
	echo ${STATUS} |  grep CREATE_IN_PROGRESS  > /dev/null 
	if [ $? -eq 0 ] ; then
	    echo "EKS cluster Stack creation is in progress ${STATUS}... waiting"
	    sleep 60
	else
	    echo "EKS cluster Stack creation status is ${STATUS} breaking the loop"
	    break
	fi
    done
    echo ${STATUS} |  grep CREATE_COMPLETE  > /dev/null 
    if [ $? -eq 0 ] ; then
       echo "EKS cluster Stack creation completed successfully"
    else
       echo "EKS cluster Stack creation failed with status ${STATUS}.. exiting"
       exit 1 
    fi
}

function update_config()
{
    aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME}
}

function update_eks()
{
    echo "Enabling clusters to use iam oidc"
    eksctl utils associate-iam-oidc-provider --cluster ${EKS_CLUSTER_NAME} --region ${AWS_REGION} --approve
}

function install_loadbalancer()
{

    echo "Installing load balancer"
    eksctl create iamserviceaccount \
     --cluster=${EKS_CLUSTER_NAME} \
     --namespace=${EKS_NAMESPACE} \
     --name=aws-load-balancer-controller \
     --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
     --override-existing-serviceaccounts \
     --approve

    helm repo add eks https://aws.github.io/eks-charts

    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
     --set clusterName=${EKS_CLUSTER_NAME} \
     --set serviceAccount.create=false \
     --set region=${AWS_REGION} \
     --set vpcId=${VPCID} \
     --set serviceAccount.name=aws-load-balancer-controller \
     -n ${EKS_NAMESPACE}

}

function install_cluster_auto_scaler()
{

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

    aws iam create-policy --policy-name k8s-asg-policy  --policy-document file://~/environment/cluster-autoscaler/k8s-asg-policy.json

    eksctl create iamserviceaccount \
        --name cluster-autoscaler \
        --namespace kube-system \
        --cluster ${EKS_CLUSTER_NAME} \
        --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/k8s-asg-policy" \
        --approve \
        --override-existing-serviceaccounts

    kubectl apply -f https://www.eksworkshop.com/beginner/080_scaling/deploy_ca.files/cluster-autoscaler-autodiscover.yaml

    # we need to retrieve the latest docker image available for our EKS version
    K8S_VERSION=$(kubectl version --short | grep 'Server Version:' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -d. -f1,2)
    AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})

    kubectl -n kube-system \
        set image deployment.apps/cluster-autoscaler \
        cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v${AUTOSCALER_VERSION}

}


function install_metric_server()
{
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.1/components.yaml
}


function install_aws_loadbalancer_controller()
{

    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/install/iam_policy.json
    curl -o iam_policy_v1_to_v2_additional.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/install/iam_policy_v1_to_v2_additional.json

    aws iam create-policy \
      --policy-name AWSLoadBalancerControllerIAMPolicy \
      --policy-document file://iam_policy.json

    aws iam create-policy \
      --policy-name AWSLoadBalancerControllerAdditionalIAMPolicy \
      --policy-document file://iam_policy_v1_to_v2_additional.json

    eksctl create iamserviceaccount \
      --cluster ${EKS_CLUSTER_NAME} \
      --namespace kube-system \
      --region $AWS_REGION \
      --name aws-load-balancer-controller \
      --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy" \
      --override-existing-serviceaccounts \
      --approve

    myrole=$(eksctl get iamserviceaccount --cluster ${EKS_CLUSTER_NAME} --region ${AWS_REGION} --name aws-load-balancer-controller --namespace kube-system -o json | jq '.[].status.roleARN' | awk -F/ '{print $2}' |awk -F\" '{print $1}')

    echo ${myrole}

    aws iam attach-role-policy \
      --role-name ${myrole} \
      --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerAdditionalIAMPolicy

    kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master

    kubectl get crd

    helm repo add eks https://aws.github.io/eks-charts

    helm install aws-load-balancer-controller \
        eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=${EKS_CLUSTER_NAME} \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller

    kubectl -n kube-system rollout status deployment aws-load-balancer-controller

    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.1/components.yaml
    sleep 30
    kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'

}

EKS_CFN_FILE=kubernetes_cluster.yaml
EKS_STACK_NAME=auroragdbk8s

AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text) 
EKS_CLUSTER_NAME=$(aws cloudformation describe-stacks --region ${AWS_REGION} --query "Stacks[].Outputs[?(OutputKey == 'EKSClusterName')][].{OutputValue:OutputValue}" --output text)
vpcid=$(aws cloudformation describe-stacks --region ${AWS_REGION} --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
subnets=$(aws ec2 describe-subnets --region ${AWS_REGION} --filters Name=vpc-id,Values=${vpcid} --query 'Subnets[?(! MapPublicIpOnLaunch)].{SubnetId:SubnetId}' --output text)

subnetA=`echo "${subnets}" |head -1 | tail -1`
subnetB=`echo "${subnets}" |head -2 | tail -1`
subnetC=`echo "${subnets}" |head -3 | tail -1`

#create_eks_cluster
update_config
update_eks
#install_loadbalancer
#install_cluster_auto_scaler
#install_metric_server
install_aws_loadbalancer_controller
