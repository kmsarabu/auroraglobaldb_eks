#!/bin/bash

iamrole=$(aws cloudformation describe-stacks --stack-name EKSGDBR --query 'Stacks[].Outputs[?(OutputKey == `Cloud9Role`)][].{OutputValue:OutputValue}'   --output text)
vpcid=$(aws cloudformation describe-stacks --stack-name EKSGDBR --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
instid=$(aws ec2 describe-instances --filters Name=vpc-id,Values=${vpcid} --query 'Reservations[].Instances[].InstanceId' --output text)

aws iam create-instance-profile --instance-profile-name cloud9InstanceProfile

aws iam add-role-to-instance-profile --role-name ${iamrole} --instance-profile-name cloud9InstanceProfile

sleep 5

aws ec2 associate-iam-instance-profile --iam-instance-profile Name=cloud9InstanceProfile --instance-id ${instid}

rm -vf ${HOME}/.aws/credentials

export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region $AWS_REGION))

test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set

echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
echo "export AZS=(${AZS[@]})" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region

export MASTER_ARN=$(aws kms describe-key --key-id alias/adbtest9 --query KeyMetadata.Arn --output text)

echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile

