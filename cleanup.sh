#!/bin/bash

REGION1=us-east-2
REGION2=us-west-2

kubectl delete services,deployments,statefulsets -n octank

eksctl delete cluster --name eksgdbclu -r us-east-2 --force -w
eksctl delete cluster --name eksgdbclu -r us-west-2 --force -w

aws efs delete-file-system --file-system-id=EFS_VOLUME_ID

aws iam delete-policy k8s-asg-policy

VPCID1=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --region ${REGION1} --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
CIDR1=$(aws ec2 describe-vpcs --vpc-ids "${VPCID1}" --region ${REGION1} --query 'Vpcs[].CidrBlock' --output text)
VPCID2=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --region ${REGION2} --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
CIDR2=$(aws ec2 describe-vpcs --vpc-ids "${VPCID2}" --region ${REGION2} --query 'Vpcs[].CidrBlock' --output text)

VPCPEERID=$(aws ec2 describe-vpc-peering-connections --region ${REGION1} --query "VpcPeeringConnections[?(RequesterVpcInfo.VpcId == '${VPCID1}')].VpcPeeringConnectionId" --output text)

aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id ${VPCPEERID} --region ${REGION1}
aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id ${VPCPEERID} --region ${REGION2}

aws cloudformation delete-stack --stack-name gdb-managed-ep ${REGION2}
aws cloudformation delete-stack --stack-name gdb-managed-ep ${REGION1}

aws cloudformation delete-stack --stack-name EKSGDB2 --region ${REGION2}
aws cloudformation delete-stack --stack-name EKSGDB1 --region ${REGION2}
aws cloudformation delete-stack --stack-name EKSGDB1 --region ${REGION1}
