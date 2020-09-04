# Fix problem with Docker
sudo usermod -aG docker ubuntu
sudo chmod 666 /var/run/docker.sock

# Sync .m2 with backet 
[ ! -d "${WORKSPACE}/.m2" ]  && mkdir -p ${WORKSPACE}/.m2 
aws s3 sync  s3://${BUCKET}/.m2 ${WORKSPACE}/.m2/
# Create image from docker file
DOCKER_BUILDKIT=1 docker build . --tag ${NAME}:${BUILD_NUMBER} -f /path/to/dockerfile --progress=plain
aws s3 sync ${WORKSPACE}/.m2/ s3://${BUCKET}/.m2 
