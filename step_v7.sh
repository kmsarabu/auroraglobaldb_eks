#!/bin/bash

CLUSTER_NAME=eksgdbclu
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.vpcId" --output text)
CIDR_BLOCK=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query "Vpcs[].CidrBlock" --output text)

MOUNT_TARGET_GROUP_NAME="eks-efs-group"
MOUNT_TARGET_GROUP_DESC="NFS access to EFS from EKS worker nodes"
MOUNT_TARGET_GROUP_ID=$(aws ec2 create-security-group --group-name $MOUNT_TARGET_GROUP_NAME --description "$MOUNT_TARGET_GROUP_DESC" --vpc-id $VPC_ID | jq --raw-output '.GroupId')
aws ec2 authorize-security-group-ingress --group-id $MOUNT_TARGET_GROUP_ID --protocol tcp --port 2049 --cidr $CIDR_BLOCK

FILE_SYSTEM_ID=$(aws efs create-file-system | jq --raw-output '.FileSystemId')

aws efs describe-file-systems --file-system-id $FILE_SYSTEM_ID
if [[ $? -ne 0 ]]; then
 echo "ERROR: Unable to create efs, pls fix and retry"
 exit 1
fi

TAG1=tag:alpha.eksctl.io/cluster-name
TAG2=tag:kubernetes.io/role/elb
subnets=($(aws ec2 describe-subnets --filters Name=vpc-id,Values=${VPC_ID} --query 'Subnets[?(! MapPublicIpOnLaunch)].SubnetId' --output text))

for subnet in ${subnets[@]}
do
    echo "creating mount target in " $subnet
    aws efs create-mount-target --file-system-id $FILE_SYSTEM_ID --subnet-id $subnet --security-groups $MOUNT_TARGET_GROUP_ID
done

sleep 60

aws efs describe-mount-targets --file-system-id $FILE_SYSTEM_ID | jq --raw-output '.MountTargets[].LifeCycleState'

kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.0"

kubectl get pods -n kube-system

roendpoint=$(aws rds describe-db-clusters --query 'DBClusters[?(TagList[?(Key == `Application` && Value == `EKSAURGDB`)])].ReaderEndpoint' --output text)
ENCODEDVALUE=$(echo -n $roendpoint | base64 --wrap=0)

sed -i "s/EFS_VOLUME_ID/$FILE_SYSTEM_ID/g" retailapp/eks/octank_app-${AWS_REGION}.yml

sed -i "s/ROENDPOINT/$ENCODEDVALUE/g" retailapp/eks/octank_app-${AWS_REGION}.yml

