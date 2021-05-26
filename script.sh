#!/bin/sh

# Using positional parameters
# First parameter is the MUP command to run. Either "DEPLOY" or "SETUP"
mode=$1;
meteor_deploy_path=$2;
gpg_key=$3

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

# Check GPG key
if [ "${gpg_key}" = "" ]; then
	echo "Invalid GPG key passed!"
	exit 1
fi

echo $gpg_key > keyfile.gpg

# # Instal git crypt
echo "Installing git crypt...."
pwd
ls
cd ..
wget https://www.agwa.name/projects/git-crypt/downloads/git-crypt-0.6.0.tar.gz
tar -xf git-crypt-0.6.0.tar.gz
cd git-crypt-0.6.0
make
make install PREFIX=/usr/local

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

# # Get GPG key
echo "Importing GPG key...."
echo -e $gpg_key > keyfile.gpg
cat keyfile.gpg
gpg --import ./keyfile.gpg
gpg --list-secret-keys
pwd
ls
cd build
pwd
ls

# # Unlock rpeo
echo "Unlocking repository...."
git-crypt unlock
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