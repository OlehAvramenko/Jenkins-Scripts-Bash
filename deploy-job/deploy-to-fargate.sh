# ------------ CERATE A SERVICE ---------------

REVISION=`aws ecs describe-task-definition --region ${REGION} --task-definition Uniform-fargate --query 'taskDefinition.revision'`

aws ecs create-service --cluster ${CLUSTER} --region ${REGION} --service-name ${SERVICE_NAME}-${BUILD_NUMBER} --task-definition ${CLUSTER}-fargate:${REVISION} --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[${SUBNET}],securityGroups=[${SECURITY_GROUP}]}"

# --------------- CHECK OLD SERVICES AND DELETE IF IT EXISTS ----------------

VERSION=`curl --user aoleh:${TOKEN} ${JENKINS_URL}/job/uniform-deploy/lastSuccessfulBuild/buildNumber`

aws ecs delete-service --region ${REGION} --cluster ${CLUSTER} --service ${SERVICE_NAME}-${VERSION} --force || \
echo " ----------- NO ACTIVE SERVICES ---------"
