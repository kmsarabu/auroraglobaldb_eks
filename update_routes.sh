#!/bin/bash

REGION1=us-east-2
REGION2=us-west-2

VPCID1=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --region ${REGION1} --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
CIDR1=$(aws ec2 describe-vpcs --vpc-ids "${VPCID1}" --region ${REGION1} --query 'Vpcs[].CidrBlock' --output text)
VPCID2=$(aws cloudformation describe-stacks --stack-name EKSGDB1 --region ${REGION2} --query 'Stacks[].Outputs[?(OutputKey == `VPC`)][].{OutputValue:OutputValue}' --output text)
CIDR2=$(aws ec2 describe-vpcs --vpc-ids "${VPCID2}" --region ${REGION2} --query 'Vpcs[].CidrBlock' --output text)

aws ec2 create-vpc-peering-connection \
 --peer-vpc-id ${VPCID2} --vpc-id ${VPCID1} \
 --region ${REGION1} \
 --peer-region ${REGION2}

VPCPEERID=$(aws ec2 describe-vpc-peering-connections --region ${REGION1} --query "VpcPeeringConnections[?(RequesterVpcInfo.VpcId == '${VPCID1}')].VpcPeeringConnectionId" --output text)

aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id ${VPCPEERID} --region ${REGION2}

query="RouteTables[?(VpcId == '${VPCID1}')].RouteTableId"
rtidlist=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=${VPCID1} --region ${REGION1} --query "$query" --output text)
for rtid in $rtidlist
do
   aws ec2 create-route --region ${REGION1} \
    --destination-cidr-block ${CIDR2} \
    --route-table-id ${rtid} \
    --vpc-peering-connection-id ${VPCPEERID}
done

query="RouteTables[?(VpcId == '${VPCID2}')].RouteTableId"
rtidlist=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=${VPCID2} --region ${REGION2} --query "$query" --output text)
for rtid in $rtidlist
do
   aws ec2 create-route --region ${REGION2} \
    --destination-cidr-block ${CIDR1} \
    --route-table-id ${rtid} \
    --vpc-peering-connection-id ${VPCPEERID}
done

## Update Aurora Cluster security group to allow connectivity between regions
SG1=$(aws rds describe-db-clusters --region $REGION1 --query 'DBClusters[?(DBClusterIdentifier == `adbtest`)].VpcSecurityGroups[].VpcSecurityGroupId' --output text)
aws ec2 authorize-security-group-ingress \
      --group-id ${SG1} \
      --ip-permissions IpProtocol=tcp,FromPort=5432,ToPort=5432,IpRanges=[{CidrIp=${CIDR2}}] \
      --region ${REGION1}

SG2=$(aws rds describe-db-clusters --region $REGION2 --query 'DBClusters[?(DBClusterIdentifier == `adbtest`)].VpcSecurityGroups[].VpcSecurityGroupId' --output text)
aws ec2 authorize-security-group-ingress \
      --group-id ${SG2} \
      --ip-permissions IpProtocol=tcp,FromPort=5432,ToPort=5432,IpRanges=[{CidrIp=${CIDR1}}] \
      --region ${REGION2}
