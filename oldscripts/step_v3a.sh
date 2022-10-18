#!/bin/bash

REGION1="us-east-2"
REGION2="us-west-2"

export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set

iamrole=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `Cloud9Role`)][].{OutputValue:OutputValue}' --region $REGION1  --output text)
vpcid=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
instid=$(aws ec2 describe-instances --filters Name=vpc-id,Values=${vpcid} --query 'Reservations[].Instances[].InstanceId' --output text)

#if [[ "${AWS_REGION}" == "${REGION1}" ]]; then
  aws iam create-instance-profile --instance-profile-name cloud9InstanceProfile
  aws iam add-role-to-instance-profile --role-name ${iamrole} --instance-profile-name cloud9InstanceProfile
  echo "Waiting for 60 seconds.."
  sleep 60
#fi

