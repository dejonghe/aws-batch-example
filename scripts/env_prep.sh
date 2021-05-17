#!/bin/bash 
set -e
# Set variables
logfile=prep.log
base_home_dir=aws-batch-example
lambda_code_path=lambda
lambda_func_name=trigger
lambda_pkg_name=${lambda_func_name}.zip
temp_path=${lambda_code_path}/.temp

docker_path=docker
start_repo_name=batchpocstart
start_docker_path=${docker_path}/${start_repo_name}
proc_repo_name=batchpocprocess
proc_docker_path=${docker_path}/${proc_repo_name}

# Define Usage
function usage()
{
  echo "Usage: $0 {args}"
  echo "Where valid args are: "
  echo "  -b <bucket> (REQUIRED) -- bucket name to sync to"
  echo "  -p <profile> -- Profile to use for AWS commands, defaults to 'default'"
  echo "  -r <release> -- Release variable used for bucket path, defaults to 'develop'"
  exit 1
}

# Builds and send the trigger lambda to s3
function build_lambda()
{
  # Make a temp dir to build in 
  mkdir -p ${temp_path}

  # Copy code to the temp path
  cp ${lambda_code_path}/${lambda_func_name}/* ${temp_path}

  # Install requirements to temp path
  cd ${temp_path}
  pip install -r requirements.txt -t .

  # Make a build directory and zip up the build package
  zip -r ../${lambda_pkg_name} ./*

  # Move back home
  numbdirs=$(awk -F"/" '{print NF-1}' <<< "./${temp_path}")
  for i in $(seq 1 ${numbdirs}); do cd ../;done

  # Remove the temparary build dir
  rm -r ${temp_path}

  local_pkg_path=${lambda_code_path}/${lambda_pkg_name}
  aws s3 cp ${local_pkg_path} s3://${BUCKET}/${RELEASE}/${lambda_code_path}/${lambda_pkg_name} --profile ${PROFILE} --exclude *.git/* --exclude *.swp

}

# Create ECR repos and get login token
function setup_ecr()
{
  # Check to see if image repository exists
  # If the start repo does not exist create it
  repos=$(aws ecr describe-repositories --profile ${PROFILE} --query "repositories[].repositoryName" --output text)
  [[ $repos =~ (^|[[:space:]])${1}($|[[:space:]]) ]] && echo 'Repo Exists' || aws ecr create-repository --profile ${PROFILE} --repository-name ${1}
  #for repo in $repos
  #do
    #if [ $repo = ${1} ]
    #then
      #exit 0
    #fi
    #aws ecr create-repository --profile ${PROFILE} --repository-name ${1}
  #done
}

# Builds and tags docker containers 
# Takes 3 parameters, directory, image tag, and repo domain
function build_docker()
{
  # Move into the docker dir
  cd ${1}
  
  # Build the image
  docker build -t ${2} .

  # Tag 
  docker tag ${2}:latest ${3}/${2}:latest
  # Push
  docker push ${3}/${2}:latest
  
  # Move back home
  numbdirs=$(awk -F"/" '{print NF-1}' <<< "./${1}")
  for i in $(seq 1 ${numbdirs}); do cd ../;done
}

# Parse args
if [[ "$#" -lt 2 ]] ; then
  echo 'parse error'
  usage
fi
PROFILE=default
RELEASE=develop
while getopts "p:r:b:" opt; do
  case $opt in
    p)
      PROFILE=$OPTARG
    ;;
    b)
      BUCKET=$OPTARG
    ;;
    r)
      RELEASE=$OPTARG
    ;;
    \?)
      echo "Invalid option: -$OPTARG"
      usage
    ;;
  esac
done

# Makes sure you're in the right directory
CWD=$(echo $PWD | rev | cut -d'/' -f1 | rev)
if [ $CWD != ${base_home_dir} ]
then
  echo "These tools are expecting to be ran from the base of the aws-batch-example repo. If you edited the name of the directory edit the env_prep.sh script."
  exit 1
fi

echo -e "Starting prep process.\nIf this script does not report success check the log.\nLogs can be found at ${logfile}"
{

# Setup AWS vars
REGION=$(aws configure list --profile ${PROFILE} | grep region | awk '{print $2}')
ACCOUNT_ID=$(aws ec2 describe-security-groups --query 'SecurityGroups[0].OwnerId' --output text --profile ${PROFILE})

# Build your lambda
build_lambda

# Setup the ECR repositories
setup_ecr ${start_repo_name}
setup_ecr ${proc_repo_name}


# Get docker credentials for the repositories
# outdated command from v1
# aws ecr get-login --no-include-email --profile ${PROFILE} | bash
# This command is supported using the latest version of AWS CLI version 2 or in v1.17.10 or later of AWS CLI version 1
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build and push docker images
build_docker ${start_docker_path} ${start_repo_name} ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
build_docker ${proc_docker_path} ${proc_repo_name} ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

}  1> $logfile
echo -e "Successfully finished prep.\n  Lambda built\n  ECR setup\n  Docker containers built and pushed"
