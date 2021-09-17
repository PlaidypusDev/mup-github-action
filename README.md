# Meteor Up GitHub Action

A GitHub action to deploy an application using [Meteor Up](http://meteor-up.com/)

#### Example usage:

```yaml
jobs:
    deploy_to_staging:
        runs-on: ubuntu-latest
        name: Deploy Meteor application to staging
        # Note: The MUP action does not handle git-crypt and SSH key management.
        # That is why this example includes an action for SSH keys and an action for git-crypt.
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
            - id: "deploy_to_staging"
              uses: PlaidypusDev/mup-github-action@v1.2
              with:
                  mode: "DEPLOY"
                  meteor_deploy_path: ".deploy/staging"
                  package_manager: "YARN"
```

#### Variables:

-   `mode` - Specifies what the MUP CLI should do. Either `SETUP`, `DEPLOY`, or `RESTART`.
-   `meteor_deploy_path` - The relative path from the repository root to the folder containing `mup.js` and `settings.json`. This is how you decide what environment to run MUP for.
-   `package_manager` - Which node package manager your Meteor project uses. Either `YARN` or `NPM`.
-   `project_path` - (Optional. Defaults to `.`). Define a path to go to for the meteor project relative. Useful for a repo that contains the source code for a Meteor app and a mobile app.
