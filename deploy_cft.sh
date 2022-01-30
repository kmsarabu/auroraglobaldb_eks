#!/bin/bash

REGION1=us-east-2
REGION2=us-west-2

function wait_for_stack_to_complete() {
  stackname=${1}
  region=${2}
  while [[ true ]]; do
    status=$(aws cloudformation describe-stacks --region ${region} --query "Stacks[?(StackName == '${stackname}')].StackStatus" --output text)
    if [[ "${status}" == "CREATE_COMPLETE" ]]; then
       echo "Stack ${stackname} on region ${region} completed (${status})"
       return
    fi
    sleep 60
  done
}

## MAIN
aws cloudformation create-stack --stack-name EKSGDB1 \
         --disable-rollback \
	 --template-body file://aurora_vpc_region.json \
	 --tags Key=Environment,Value=EKSGDB \
	 --timeout-in-minutes=30 --region ${REGION1} \
	 --capabilities "CAPABILITY_IAM" \
	 --parameters ParameterKey=DeployAurora,ParameterValue=true ParameterKey=ClassB,ParameterValue=40
if [[ $? -ne 0 ]]; then
  echo "Stack aurora_vpc_region.json, EKSGDB1 failed to deploy on region ${REGION1}, Please check/fix the error and retry"
  exit 1
fi
wait_for_stack_to_complete "EKSGDB1" "${REGION1}"

aws cloudformation create-stack --stack-name EKSGDB1 \
	 --template-body file://aurora_vpc_region.json \
	  --tags Key=Environment,Value=EKSGDB \
	   --timeout-in-minutes=30 --region ${REGION2} \
	    --capabilities "CAPABILITY_IAM" \
	     --parameters ParameterKey=DeployAurora,ParameterValue=false ParameterKey=ClassB,ParameterValue=50
if [[ $? -ne 0 ]]; then
	echo "Stack aurora_vpc_region.json, EKSGDB1 failed to deploy on region ${REGION2}, Please check/fix the error and retry"
  exit 1
fi
wait_for_stack_to_complete "EKSGDB1" "${REGION2}"
 
aws cloudformation create-stack --stack-name EKSGDB2 \
	 --template-body file://aurora_gdb.json \
	  --tags Key=Environment,Value=EKSGDB \
	   --timeout-in-minutes=30 --region ${REGION2}

if [[ $? -ne 0 ]]; then
  echo "Stack aurora_gdb.json, EKSGDB2 failed to deploy on region ${REGION1}, Please check/fix the error and retry"
  exit 1
fi
wait_for_stack_to_complete "EKSGDB2" "${REGION2}"

echo "Completed deloying the CloudFormation Stacks on regions us-east-2 and us-west-2"

