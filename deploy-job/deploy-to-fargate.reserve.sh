#!/bin/bash

SERVICE=$(aws ecs list-services --cluster ${CLUSTER} | grep -c ${SERVICE_NAME})
if [[ $SERVICE -gt 0 ]]; then
  echo "Updating service"
  aws ecs update-service --cluster ${CLUSTER} --service ${SERVICE_NAME} --force-new-deployment
else
  echo "Creating task definition"
  tee "fargate-task.json" > "/dev/null" <<EOF
{
"family": "${SERVICE_NAME}-fargate",
"executionRoleArn": "${NAME_ROLE}",
"networkMode": "awsvpc",
"containerDefinitions": [
  {
    "name": "${SERVICE_NAME}-task",
    "image": "${IMAGE}:latest",
    "portMappings": [
      {
        "containerPort": 8080,
        "protocol": "tcp"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "MYSQL_USER",
        "value": "$DB_USER"
      },
      {
        "name": "MYSQL_PASS",
        "value": "$DB_PASS"
      },
      {
        "name": "MYSQL_URL",
        "value": "jdbc:mysql://$DB_URL:$DB_PORT/$DB_NAME"
      }
    ]
  }
],
"requiresCompatibilities": [ "FARGATE" ],
"cpu": "1024",
"memory": "2048"
}
EOF

  echo "Registering task definition"
  aws ecs register-task-definition --region ${REGION}  --cli-input-json file://fargate-task.json
  
  echo "Creating service"
  REVISION=$(aws ecs describe-task-definition --region ${REGION} --task-definition ${SERVICE_NAME}-fargate --query 'taskDefinition.revision')
  aws ecs create-service --region ${REGION} --cluster ${CLUSTER} --service-name ${SERVICE_NAME} --task-definition ${SERVICE_NAME}-fargate:"$REVISION" --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${SUBNET_ID}],securityGroups=[${SECURITY_GROUP}]}"
  
fi
