AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
LAMBDA_ROLE="aurorapgbouncerlambda"
LAYER_NAME="kubernetes"
LAMBDA_NAME="AuroraGDBPgbouncerUpdate"
EVENT_NAME=${LAMBDA_NAME}

current_dir=`pwd`
cd /tmp

pip3 install kubernetes -t python/
zip -r kubernetes.zip python  > /dev/null
aws lambda publish-layer-version --layer-name ${KUBERNETES} --zip-file fileb://kubernetes.zip --compatible-runtimes python3.9 --region ${AWS_REGION}

layer_arn=$(aws lambda  get-layer-version --layer-name ${LAYER_NAME} --version-number 1 | jq -r .LayerVersionArn)
echo ${layer_arn}

cd ${current_dir}

zip -r /tmp/aurora_gdb_update.zip aurora_gdb_update.py

aws iam create-role --role-name ${LAMBDA_ROLE} --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'
aws iam attach-role-policy --role-name ${LAMBDA_ROLE} --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam put-role-policy --role-name ${LAMBDA_ROLE} --policy-name lambda_rds_policy --policy-document  '{"Version": "2012-10-17","Statement": [{ "Action": ["sts:GetCallerIdentity","eks:DescribeCluster","rds:DescribeDBClusters"],"Effect": "Allow","Resource": "*"}]}'

lambda_role_arn=$(aws iam get-role --role-name ${LAMBDA_ROLE} | jq -r .Role.Arn)
echo ${lambda_role_arn}

aws lambda create-function --function-name ${LAMBDA_NAME} --zip-file fileb:///tmp/aurora_gdb_update.zip --handler aurora_gdb_update.lambda_handler --runtime python3.9 --role ${lambda_role_arn} --layers ${layer_arn} --timeout 600 

lambda_arn=$(aws lambda get-function --function-name ${LAMBDA_NAME} | jq -r .Configuration.FunctionArn)
echo ${lambda_arn}

aws events put-rule --name ${EVENT_NAME} --event-pattern "{\"detail-type\": [\"RDS DB Cluster Event\"],\"source\": [\"aws.rds\"],\"detail\": {\"EventCategories\": [\"global-failover\"],\"EventID\": [\"RDS-EVENT-0185\"]}}" 

aws events put-targets --rule ${EVENT_NAME} --targets "Id"="1","Arn"="${lambda_arn}"

ROLE="    - rolearn: ${lambda_role_arn}\n      username: lambda\n      groups:\n        - system:masters"
kubectl get -n kube-system configmap/aws-auth -o yaml | awk "/mapRoles: \|/{print;print \"$ROLE\";next}1" > /tmp/aws-auth-patch.yml
kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"

kubectl apply -f lambda_role_binding.yaml
