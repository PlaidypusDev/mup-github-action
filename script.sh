#!/bin/sh

# Using positional parameters
# First parameter is the MUP command to run. Either "DEPLOY" or "SETUP"
mode=$1;
meteor_deploy_path=$2;

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

# # Install meteor
echo "Installing Meteor...."
pwd
ls
curl https://install.meteor.com/ | sh
export METEOR_ALLOW_SUPERUSER=true

# # Go back to root level
cd ..
pwd
ls

# # Install meteor and mup
echo "Instaling MUP...."
npm install --global mup

# # Install dependenices
echo "Installing dependencies...."
npm ci

# CD into meteor deploy directory
cd $meteor_deploy_path
pwd
ls

# Running specified command
if [ "${mode}" = "DEPLOY" ]; then
	echo "Deploy"
elif [ "${mode}" = "SETUP" ]; then
	echo "Setup"
fi