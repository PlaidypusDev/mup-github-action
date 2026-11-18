#!/bin/sh

# Using positional parameters
# First parameter is the MUP command to run. Either "DEPLOY", "SETUP", or "RESTART"
# Second parameter is the meteor deploy path
# Third parameter is the node package manager to use. Either "NPM" or "YARN"
# Fourth parameter is the absolute path of the repository
# fifth parameter is the folder that contains the package.json for the Meteor app. Defaults to the current directory.
# sixth parameter is a string of the name of the server for the action to target. Example: two
mode=$1;
meteor_deploy_path=$2;
node_package_manager=$3
repository_path=$4
project_path=$5
server=$6

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

servers_option=""

if [ "${server}" != "" ]; then
    servers_option="--servers ${server}"
fi

# Go to the root level
cd ~/

export METEOR_ALLOW_SUPERUSER=true

# Install meteor
# RESTART doesn't build the app, so it doesn't need Meteor. Skipping the install keeps
# a restart from replacing the Meteor version that deploys depend on.
if [ "${mode}" = "RESTART" ]; then
	echo "Skipping Meteor install for RESTART"
else
	# Install the Meteor release the project pins in .meteor/release, not the latest
	meteor_release_file="${repository_path}/${project_path}/.meteor/release"
	meteor_release=$(sed -n 's/^METEOR@//p' "${meteor_release_file}" 2>/dev/null | tr -d '[:space:]')

	if [ "${meteor_release}" = "" ]; then
		echo "ERROR: No Meteor release found in ${meteor_release_file}. Check the project_path input."
		exit 1
	fi

	echo "Installing Meteor ${meteor_release} (from ${meteor_release_file})..."
	meteor_installer=$(curl -fsSL "https://install.meteor.com/?release=${meteor_release}")
	if [ $? -ne 0 ] || [ "${meteor_installer}" = "" ]; then
		echo "ERROR: Could not download the Meteor ${meteor_release} installer."
		exit 1
	fi
	if ! printf '%s\n' "${meteor_installer}" | sh; then
		echo "ERROR: Meteor ${meteor_release} install failed."
		exit 1
	fi

	# Make sure the installed Meteor actually runs on this machine and is the pinned version
	installed_version=$("$HOME/.meteor/meteor" --version 2>&1)
	if ! printf '%s\n' "${installed_version}" | grep -Fqx "Meteor ${meteor_release}"; then
		echo "ERROR: Expected 'Meteor ${meteor_release}' after install but got:"
		echo "${installed_version}"
		exit 1
	fi
	echo "Meteor ${meteor_release} installed and verified."
fi

# Go to the project
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

# Go back to the project root
cd $repository_path

# cd into meteor deploy directory
cd $meteor_deploy_path

# Running specified command
if [ "${mode}" = "DEPLOY" ]; then
	echo "Deploying using config from ${meteor_deploy_path}..."
	mup deploy --verbose $servers_option
elif [ "${mode}" = "SETUP" ]; then
	echo "Setting up using config from ${meteor_deploy_path}..."
	mup setup --verbose $servers_option
elif [ "${mode}" = "RESTART" ]; then
	echo "Restarting..."
	mup restart $servers_option
fi