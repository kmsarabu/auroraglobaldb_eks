#!/bin/bash

REGION1="us-east-2"
REGION2="us-west-2"

export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set

iamrole=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `Cloud9Role`)][].{OutputValue:OutputValue}' --region $REGION1  --output text)
vpcid=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
instid=$(aws ec2 describe-instances --filters Name=vpc-id,Values=${vpcid} --query 'Reservations[].Instances[].InstanceId' --output text)

output=$(aws ec2 describe-iam-instance-profile-associations --filters Name=instance-id,Values=${instid} --query 'IamInstanceProfileAssociations[].IamInstanceProfile.Arn' --output text)

echo  "${output}" | egrep "cloud9InstanceProfile" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
   if [[ -n "${output}" ]]; then
        associd=$(aws ec2 describe-iam-instance-profile-associations --filters Name=instance-id,Values=${instid} --query 'IamInstanceProfileAssociations[].AssociationId' --output text)
	aws ec2 disassociate-iam-instance-profile --association-id ${associd}
   fi
   aws ec2 associate-iam-instance-profile --iam-instance-profile Name=cloud9InstanceProfile --instance-id ${instid}
   if [[ $? -ne 0 ]]; then
	echo Error in associating instance profile, pls chk, fix and retry
        exit 1
   fi
fi

echo "Waiting for changes to take effect"
sleep 60

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

keyid=$AWS_ACCESS_KEY_ID
skey=$AWS_SECRET_ACCESS_KEY
defreg=$AWS_DEFAULT_REGION

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION

aws sts get-caller-identity --query Arn | grep $iamrole -q && echo "IAM role valid" || echo "IAM role NOT valid"

export AWS_ACCESS_KEY_ID=$keyid
export AWS_SECRET_ACCESS_KEY=$skey
export AWS_DEFAULT_REGION=$defreg

