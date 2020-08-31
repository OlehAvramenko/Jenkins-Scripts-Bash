# ------------ CERATE A SERVICE ---------------

REVISION=`aws ecs describe-task-definition --region ${REGION} --task-definition ${CLUSTER}-fargate --query 'taskDefinition.revision'`

aws ecs create-service --cluster ${CLUSTER} --region ${REGION} --service-name ${SERVICE_NAME}-${BUILD_NUMBER} --task-definition ${CLUSTER}-fargate:${REVISION} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${SUBNET_ID}],securityGroups=[${SECURITY_GROUP}]}"

# --------------- CHECK OLD SERVICES AND DELETE IF IT EXISTS ----------------

VERSION=`curl --user ${JENKINS_USER}:${TOKEN} ${JENKINS_URL}/job/${JOB_NAME}/lastSuccessfulBuild/buildNumber`

aws ecs delete-service --region ${REGION} --cluster ${CLUSTER} --service ${SERVICE_NAME}-${VERSION} --force || \
echo " ----------- NO ACTIVE SERVICES ---------"
