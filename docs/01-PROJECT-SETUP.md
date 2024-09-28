# Project setup

Here's how to set up a new project based on this template:

1. Fork this repository

1. <details>
    <summary>Create a new workspace in Terraform Cloud</summary>

    1. Use the VCS workflow, selecting the newly forked Github repository
    1. Enter `infrastructure` under the working directory
    1. Specify `main` as the VCS branch
    </details>

1. <details>
    <summary>Create a new workspace in Terraform Cloud</summary>

    1. Use the VCS workflow, selecting the newly forked Github repository
    1. Enter `infrastructure` under the working directory
    1. Specify `main` as the VCS branch
    </details>

1. <details>
    <summary>Apply relevant variable set in TFC</summary>

    1. Go to your workspace variable settings
    1. Depending on who the project is for, apply the `Internal` or `Client` variable set. Depending on the set you choose, a relevant billing account and resource folder will be set for the project. In addition, `Internal` projects do not use NAT and instead open up MongoDB Atlas connections for all IPs, which simplifies the infrastructure and reduces infrastructure costs, but it is not recommended from a security POV for production projects.
    </details>

1. <details>
    <summary>Schedule and apply a new run in Terraform Cloud</summary>

    This will bootstrap the entire GCP + Mongodb Atlas infrastructure.
    </details>

1. <details>
    <summary>Set up DNS</summary>

    Note the `global_ip` output in Terraform Cloud. Then point your domain to this IP address by adding following `A` records:

    | Type | Name            | Value       | TTL       |
    | ---- | --------------- | ----------- | --------- |
    | `A`  | `@`             | `global_ip` | 1/2 hours |
    | `A`  | `development`   | `global_ip` | 1/2 hours |
    | `A`  | `test`          | `global_ip` | 1/2 hours |
    | `A`  | `staging`       | `global_ip` | 1/2 hours |

    If you're setting up a subdomain, e.g. yourproject.topdomain.com, then the records to set up are:

    | Type | Name            | Value       | TTL       |
    | ---- | --------------- | ----------- | --------- |
    | `A`  | `yourproject`   | `global_ip` | 1/2 hours |
    | `A`  | `*.yourproject` | `global_ip` | 1/2 hours |
    </details>

1. <details>
    <summary>Ping all your domains</summary>

    Ping all the domains you set up to trigger SSL generation. You can simply open all your domains in the browser.

    *NOTE: It will take a moment (usually up to 1h) for your domains to start working.*
    </details>

1. <details>
    <summary>Commit to Git to trigger deployment</summary>

    See [./02-CI-CD-WORKFLOW.md](02-CI-CD-WORKFLOW.md) for more information on the deployment workflow.
    </details>