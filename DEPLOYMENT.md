# Deployment

This action is simple to deploy. All changes are merged into `master` and once you are ready for a release you tag the commit on `master` with a semantic version string (for example: `v1.3`). Once you want to use the updated version you'll need to update your usage of the action to be

```
yml
...rest of action
- name: Deploy to Staging
  uses: PlaidypusDev/mup-github-action@v1.3 # In this example, the tag of the new version is `v1.3`.
  with:
    mode: "DEPLOY"
    meteor_deploy_path: ".deploy/staging"
    package_manager: "YARN"
```

Note that we prefix the version string with `v`, this has to be done when tagging the commit.
