# CREATE JSON FOR TASK
# ----------- CHANGE IMAGE ----------------
TAG=`aws ecr describe-images --region ${REGION} --repository-name foxtrot --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' --output text
` 
cat > fargate-task.json <<EOF 
{
    "family": "${CLUSTER}-fargate", 
    "networkMode": "awsvpc", 
    "executionRoleArn": "${ARN_IAM_ROLE}",
    "containerDefinitions": [
        {
            "name": "fargate-app-uniform", 
            "image": "${REGISTRY}:${TAG}", 
            "environment": [
                {
                    "name": "MYSQL_URL",
                    "value": "jdbc:mysql://${DB_URL}:${DB_PORT}/${DB_NAME}"
                },
            
                {
                    "name": "MYSQL_USER",
                    "value": "$DB_USER"
                },
                
                {
                    "name": "MYSQL_PASS",
                    "value": "$DB_PASS"
                }
             ],
            "portMappings": [
                {
                    "containerPort": 8080, 
                    "hostPort": 8080, 
                    "protocol": "tcp"
                }
                
                
            ], 
            "essential": true 

        }
    ], 
    "requiresCompatibilities": [
        "FARGATE"
    ], 
    "cpu": "1024", 
    "memory": "2048"
}
EOF

REVISION_OLD=`aws ecs describe-task-definition --region us-east-1 --task-definition Uniform-fargate --query 'taskDefinition.revision'`
# ------------------ CREATE task-definition ---------------------

aws ecs register-task-definition --region ${REGION}  --cli-input-json file://fargate-task.json

# ----------------- DELETE previous task-definition ---------------

aws ecs deregister-task-definition --region ${REGION} --task-definition ${CLUSTER}-fargate:${REVISION_OLD} || \
echo " --------- NO PREVIOUS TASKS ---------"




