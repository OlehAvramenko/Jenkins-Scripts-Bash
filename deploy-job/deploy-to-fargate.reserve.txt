#!/bin/bash

SERVICE=$(aws ecs list-services --cluster Kilo | grep -c Kilo)
if [[ $SERVICE -gt 0 ]]; then
  echo "Updating service"
  aws ecs update-service --cluster Kilo --service Kilo-deploy --force-new-deployment
else
  echo "Creating task definition"
  tee "fargate-task.json" > "/dev/null" <<EOF
{
"family": "kilo-fargate",
"executionRoleArn": "ecsTaskExecutionRole",
"networkMode": "awsvpc",
"containerDefinitions": [
  {
    "name": "kilo-petclinic",
    "image": "427050172059.dkr.ecr.us-east-1.amazonaws.com/charlie:latest",
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
  aws ecs register-task-definition --region us-east-1  --cli-input-json file://fargate-task.json
  
  echo "Creating service"
  REVISION=$(aws ecs describe-task-definition --region us-east-1 --task-definition kilo-fargate --query 'taskDefinition.revision')
  aws ecs create-service --region us-east-1 --cluster Kilo --service-name Kilo-deploy --task-definition kilo-fargate:"$REVISION" --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[subnet-45a4181c],securityGroups=[sg-031cad4dded62d028]}"
  
fi