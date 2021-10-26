#!/bin/bash

iamrole=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `Cloud9Role`)][].{OutputValue:OutputValue}'   --output text)
vpcid=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
instid=$(aws ec2 describe-instances --filters Name=vpc-id,Values=${vpcid} --query 'Reservations[].Instances[].InstanceId' --output text)

aws iam create-instance-profile --instance-profile-name cloud9InstanceProfile

aws iam add-role-to-instance-profile --role-name ${iamrole} --instance-profile-name cloud9InstanceProfile


