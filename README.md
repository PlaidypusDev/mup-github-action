# Meteor Up GitHub Action

A GitHub action to deploy an application using [Meteor Up](http://meteor-up.com/)

#### Example usage:

```yaml
jobs:
  deploy_to_staging:
    runs-on: ubuntu-latest
    name: Deploy Meteor application to staging
		# Note: The MUP action does not handle git-crypt and SSH key management itself.
		# That is why this example includes a step for SSH keys and a step for git-crypt.
    steps:
      - uses: actions/checkout@v2
      - name: Install SSH key
        uses: shimataro/ssh-key-action@v2
        with:
          key: ${{ secrets.SSH_KEY }}
          name: id_rsa
          known_hosts: ${{ secrets.KNOWN_HOSTS }}
          if_key_exists: replace
      - name: Unlock repo
        uses: sliteteam/github-action-git-crypt-unlock@1.2.0
        env:
          GIT_CRYPT_KEY: ${{ secrets.GPG_KEY }}
      # MUP GitHub action
      - id: 'deploy_to_staging'
        uses: PlaidypusDev/mup-github-action@v0.21
        with:
          mode: 'DEPLOY'
          meteor_deploy_path: '.deploy/staging'
	 				package_manager: 'YARN'
```

#### Variables:

-   `mode` - Specifies what the MUP CLI should do. Either `SETUP` or `DEPLOY`.
-   `meteor_deploy_path` - The relative path to the folder containing `mup.js` and `settings.json`. This is how you decide what environment to run MUP for.
-   `package_manager` - What node package manager your Meteor project uses. Either `YARN` or `NPM`.
