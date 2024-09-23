# CI/CD Workflow

## Introduction
This project uses a Gitflow worklow to facilitate Continuous Integration and Continuous Deployment.

## Documentation
Please ensure you familiarise yourself with the Gitflow workflow at https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

## Overview
This single image embraces the flow we're using:
![Gitflow workflow](https://wac-cdn.atlassian.com/dam/jcr:8f00f1a4-ef2d-498a-a2c6-8020bb97902f/03%20Release%20branches.svg "Gitflow workflow")

## Deployments
Deployments happen in the following way:
- `development` - all pushes to `develop` branch automatically deploy to `development`
- `test` - all pushes to `release/*` branches automatically deploy to `test`. NOTE: for this reason it is best to keep one active release at a time, otherwise deployments will override one another.
- `staging` - all pushes to `main` tagged with `v*` will automatically get deployed to `staging`.
- `production` - can only be deployed to by manual promotion from the `staging` environment.