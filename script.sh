#!/bin/sh

# Using positional parameters
# First parameter is the MUP command to run. Either "DEPLOY" or "SETUP"
# Second parameter is the meteor deploy path
# Third parameter is the node package manager to use. Either "NPM" or "YARN"
# Fourth parameter is the absolute path of the repository
mode=$1;
meteor_deploy_path=$2;
node_package_manager=$3
repository_path=$4

echo "Running MUP GitHub action"

# Check mode
if [ "${mode}" != "DEPLOY" ] && [ "${mode}" != "SETUP" ]; then
	echo "Invalid mode passed! Expected 'DEPLOY' or 'SETUP' but received '${mode}'"
	exit 1
fi

# Check meteor deploy path
if [ "${meteor_deploy_path}" = "" ]; then
	echo "Invalid meteor deploy path passed!"
	exit 1
fi

# Check node package manager
if [ "${node_package_manager}" != "NPM" ] && [ "${node_package_manager}" != "YARN" ]; then
	echo "Invalid node package manager passed! Expected 'NPM' or 'YARN' but received '${node_package_manager}'"
	exit 1
fi

# Check repository path
if [ "${repository_path}" = "" ]; then
	echo "Invalid repository path passed!"
	exit 1
fi

# Go to the root level
cd ~/

# Install meteor
echo "Installing Meteor...."
pwd
ls
curl https://install.meteor.com/ | sh
export METEOR_ALLOW_SUPERUSER=true

# # Go back to the project
echo "${repository_path}"
cd $repository_path
pwd
ls

# Install dependenices
echo "Installing dependencies...."
if [ "${node_package_manager}" = "NPM" ]; then
	npm ci
elif [ "${node_package_manager}" = "YARN" ]; then
	yarn install --frozen-lockfile
fi

# Install mup
echo "Installing MUP...."
# if [ "${node_package_manager}" = "NPM" ]; then
# 	npm install -g mup
# elif [ "${node_package_manager}" = "YARN" ]; then
# 	yarn global add mup
# fi
sudo npm install -g mup


# CD into meteor deploy directory
cd $meteor_deploy_path
pwd
ls

mup --help

# Running specified command
if [ "${mode}" = "DEPLOY" ]; then
	echo "Deploy"
elif [ "${mode}" = "SETUP" ]; then
	echo "Setup"
fi