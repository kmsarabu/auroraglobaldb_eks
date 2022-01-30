#!/bin/bash

REGION1="us-east-2"
REGION2="us-west-2"

Global_Accelerator_Arn=$(ws globalaccelerator list-accelerators --region us-west-2 --query 'Accelerators[?(Name == `eksgdb`)].AcceleratorArn' --output text)

if [[ -z ${Global_Accelerator_Arn} ]]; then
   Global_Accelerator_Arn=$(aws globalaccelerator create-accelerator --name eksgdb --query "Accelerator.AcceleratorArn" --output text --region us-west-2)
fi

Global_Accelerator_Listerner_Arn=$(aws globalaccelerator create-listener \
  --accelerator-arn $Global_Accelerator_Arn \
  --region us-west-2 \
  --protocol TCP \
  --port-ranges FromPort=80,ToPort=80 \
  --query "Listener.ListenerArn" \
  --output text)


lname=$(aws elbv2 describe-load-balancers --region $REGION1 --query 'LoadBalancers[?contains(DNSName, `webapp`)].LoadBalancerArn' --output text)
EndpointGroupArn_1=$(aws globalaccelerator create-endpoint-group \
  --region us-west-2 \
  --listener-arn $Global_Accelerator_Listerner_Arn \
  --endpoint-group-region ${REGION1} \
  --query "EndpointGroup.EndpointGroupArn" \
  --output text \
  --endpoint-configurations EndpointId=$lname,Weight=128,ClientIPPreservationEnabled=True) 

lname=$(aws elbv2 describe-load-balancers --region $REGION2 --query 'LoadBalancers[?contains(DNSName, `webapp`)].LoadBalancerArn' --output text)
EndpointGroupArn_2=$(aws globalaccelerator create-endpoint-group \
  --region us-west-2 \
  --traffic-dial-percentage 0 \
  --listener-arn $Global_Accelerator_Listerner_Arn \
  --endpoint-group-region $REGION2 \
  --query "EndpointGroup.EndpointGroupArn" \
  --output text \
  --endpoint-configurations EndpointId=$lname,Weight=128,ClientIPPreservationEnabled=True) 

WEBAPP_GADNS=$(aws globalaccelerator describe-accelerator \
  --accelerator-arn $Global_Accelerator_Arn \
  --query "Accelerator.DnsName" \
  --output text --region us-west-2)

export WEBAPP_GADNS

#curl $WEBAPP_GADNS/apiproduct

echo $WEBAPP_GADNS
