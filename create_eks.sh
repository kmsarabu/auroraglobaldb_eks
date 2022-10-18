#!/bin/sh

function print_line()
{
    echo "---------------------------------"
}

function chk_cloud9_permission()
{
    print_line
    echo "Fixing the cloud9 permission"
    print_line
    aws sts get-caller-identity | grep ${INSTANCE_ROLE}  
    if [ $? -ne 0 ] ; then
	echo "Fixing the cloud9 permission"
        environment_id=`aws ec2 describe-instances --region ${AWS_REGION} --instance-id $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --query "Reservations[*].Instances[*].Tags[?Key=='aws:cloud9:environment'].Value" --output text`
        aws cloud9 update-environment --environment-id ${environment_id} --region ${AWS_REGION} --managed-credentials-action DISABLE
	sleep 10
        ls -l $HOME/.aws/credentials > /dev/null 2>&1
        if [ $? -eq 0 ] ; then
             echo "!!! Credentials file exists"
        else
            echo "Credentials file does not exists"
        fi
	echo "After fixing the credentials. Current role"
        aws sts get-caller-identity | grep ${INSTANCE_ROLE} > /dev/null
        if [ $? -eq 0 ]; then
            echo "Permission set properly for the cloud9 environment"
        else
            echo "!!! Permission not set properly for the cloud9 environment"
            aws sts get-caller-identity
            exit 1
        fi
    fi
}

function create_eks_cluster()
{
    print_line
    echo "Creatingn EKS cluster"
    print_line
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
    print_line
}

function update_config()
{
    print_line
    echo "Updating kubectl config" 
    print_line
    aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}
    print_line
}

function update_eks()
{
    print_line
    echo "Enabling clusters to use iam oidc"
    print_line
    eksctl utils associate-iam-oidc-provider --cluster ${EKS_CLUSTER_NAME} --region ${AWS_REGION} --approve
    print_line
}


function install_loadbalancer()
{
    print_line
    echo "Installing load balancer"
    print_line

    eksctl create iamserviceaccount \
     --cluster=${EKS_CLUSTER_NAME} \
     --namespace=${EKS_NAMESPACE} \
     --name=aws-load-balancer-controller \
     --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
     --override-existing-serviceaccounts \
     --approve

    kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
    helm repo add eks https://aws.github.io/eks-charts

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

    print_line
    echo "Installing Auto Scaler configuration" 
    print_line
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
        --namespace ${EKS_NAMESPACE} \
        --cluster ${EKS_CLUSTER_NAME} \
        --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/k8s-asg-policy" \
        --approve \
        --override-existing-serviceaccounts

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

    kubectl -n kube-system \
        annotate deployment.apps/cluster-autoscaler \
        cluster-autoscaler.kubernetes.io/safe-to-evict="false"

    # we need to retrieve the latest docker image available for our EKS version
    K8S_VERSION=$(kubectl version --short | grep 'Server Version:' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -d. -f1,2)
    AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})

    kubectl -n kube-system \
        set image deployment.apps/cluster-autoscaler \
        cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v${AUTOSCALER_VERSION}

    print_line

}


function install_metric_server()
{
    print_line
    echo "Installing Metric Server"
    print_line
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.1/components.yaml
    sleep 30
    kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'
    print_line
}

export EKS_CFN_FILE=eks_cluster.yaml
export EKS_STACK_NAME=auroragdbeks
export INSTANCE_ROLE="C9Role"
export EKS_NAMESPACE="kube-system"

export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text) 
export EKS_CLUSTER_NAME=$(aws cloudformation describe-stacks --region ${AWS_REGION} --query "Stacks[].Outputs[?(OutputKey == 'EKSClusterName')][].{OutputValue:OutputValue}" --output text)
vpcid=$(aws cloudformation describe-stacks --region ${AWS_REGION} --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
subnets=$(aws ec2 describe-subnets --region ${AWS_REGION} --filters Name=vpc-id,Values=${vpcid} --query 'Subnets[?(! MapPublicIpOnLaunch)].{SubnetId:SubnetId}' --output text)

subnetA=`echo "${subnets}" |head -1 | tail -1`
subnetB=`echo "${subnets}" |head -2 | tail -1`
subnetC=`echo "${subnets}" |head -3 | tail -1`

chk_cloud9_permission
create_eks_cluster
update_config
update_eks
install_loadbalancer
install_cluster_auto_scaler
install_metric_server
