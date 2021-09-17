#!/bin/sh

# Using positional parameters
# First parameter is the MUP command to run. Either "DEPLOY", "SETUP", or "RESTART"
# Second parameter is the meteor deploy path
# Third parameter is the node package manager to use. Either "NPM" or "YARN"
# Fourth parameter is the absolute path of the repository
mode=$1;
meteor_deploy_path=$2;
node_package_manager=$3
repository_path=$4
project_path=$5

echo "Running MUP GitHub action..."

# Check mode
if [ "${mode}" != "DEPLOY" ] && [ "${mode}" != "SETUP" ] && [ "${mode}" != "RESTART" ]; then
	echo "Invalid mode passed! Expected 'DEPLOY', 'SETUP', or 'RESTART' but received '${mode}'"
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
echo "Installing Meteor..."
curl https://install.meteor.com/ | sh
export METEOR_ALLOW_SUPERUSER=true

# # Go back to the project
cd $repository_path
cd $project_path

# Install dependenices
echo "Installing dependencies..."
if [ "${node_package_manager}" = "NPM" ]; then
	npm ci
elif [ "${node_package_manager}" = "YARN" ]; then
	yarn install --frozen-lockfile
fi

# Install mup
echo "Installing MUP..."
sudo npm install -g mup

# CD into meteor deploy directory
cd $meteor_deploy_path

# Running specified command
if [ "${mode}" = "DEPLOY" ]; then
	echo "Deploying using config from ${meteor_deploy_path}..."
	mup deploy --verbose
elif [ "${mode}" = "SETUP" ]; then
	echo "Setting up using config from ${meteor_deploy_path}..."
	mup setup --verbose
elif [ "${mode}" = "RESTART" ]; then
	echo "Restarting..."
	mup restart
fi