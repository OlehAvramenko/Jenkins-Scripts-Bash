# push into ECR
# aws ecr get-login --no-include-email --region=us-east-1 > login
# chmod 777 login && ./login
aws ecr get-login-password --region=${REGION} | docker login --username AWS --password-stdin ${REGISTRY}

# Check for tag
check=`git tag --points-at HEAD | wc -l`
TAG=`git tag --points-at HEAD`
if [ "$check" -eq 0 ]
then 
docker tag petclinic-app:${BUILD_NUMBER} ${REGISTRY}:${BUILD_NUMBER}
docker push ${REGISTRY}:${BUILD_NUMBER}
else
docker tag ipetclinic-app:${BUILD_NUMBER} ${REGISTRY}:${TAG}_${BUILD_NUMBER}
docker push ${REGISTRY}:${TAG}_${BUILD_NUMBER}
fi
