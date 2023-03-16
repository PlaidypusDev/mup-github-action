# Meteor Up GitHub Action

A GitHub action to deploy an application using [Meteor Up](http://meteor-up.com/)

## Development

This action was built using a bash script, `script.sh`.

## Example usage

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
      - name: Deploy to Staging
        uses: PlaidypusDev/mup-github-action@v1.2
        with:
          mode: "DEPLOY"
          meteor_deploy_path: ".deploy/staging"
          package_manager: "YARN"
```

## Variables

| Name                 | Description                                                                                                                                                                                                                                                            | Type                         | Example           |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | ----------------- |
| `mode`               | What meteor up script to run. This is used to set if the script is a deploy, setup, or restart script.                                                                                                                                                                 | `SETUP`, `DEPLOY`, `RESTART` | `SETUP`           |
| `meteor_deploy_path` | The path of the `mup.js` and `settings.json` files. This is how to specify the meteor up settings.                                                                                                                                                                     | String                       | `.deploy/staging` |
| `package_manager`    | The node package manger the meteor project uses.                                                                                                                                                                                                                       | `NPM` or `YARN`              | `YARN`            |
| `project_path`       | The root path of the meteor app in the repository. This is used as a prefix for `meteor_deploy_path`. You'd want to set this when working on a monorepo where the meteor app is in a nested folder, `desktop/` for example. This is **optional** and defaults to `./`. | String`                      | `./desktop`       |
