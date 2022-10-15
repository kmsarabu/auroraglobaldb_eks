#!/bin/ksh


function create_eks_cluster()
{
    typeset -i counter
    counter=0
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

EKS_CFN_FILE=kubernetes_cluster.yaml
EKS_STACK_NAME=auroragdb_k8s

AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
vpcid=$(aws cloudformation describe-stacks --region ${AWS_REGION} --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)

subnets=$(aws ec2 describe-subnets --region ${AWS_REGION} --filters Name=vpc-id,Values=${vpcid} --query 'Subnets[?(! MapPublicIpOnLaunch)].{AvailabilityZoneId:AvailabilityZoneId,SubnetId:SubnetId}' --output text)

subnetA=`echo ${subnets} |head -1 | tail -1`
subnetB=`echo ${subnets} |head -2 | tail -1`
subnetC=`echo ${subnets} |head -3 | tail -1`

#create_eks_cluster
