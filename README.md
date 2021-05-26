Notes:

-   Git crypt GPG key needs to be stored as an environment variable in the workflow of the project that is using this action, and it then gets passed down to this action as an input.
-   Composite actions are multiple actions combined into one
    -   So going down this route we'd need an action for handling git-crypt, an action for deploying, and an action for setting up the environment.
    -   We can dictate which environment to use based off of the mup file. So we can make a parameter (?) pointing to the directory that contains the settings. (Staging: .deploy/staging, Production: .deploy/prod)
    -   However, this route requires batch script usage and that seems to over complicate the pipeline but it might be our best option. We also have to manually install node.js and npm.
-   Docker actions allow us to build a Docker image and run commands in it. We could use a linux container that has node.js/npm installed to run the mup commands.
