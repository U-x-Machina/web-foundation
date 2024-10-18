# Local development

## Setup
1. Install dependencies by running `pnpm i`
1. Initialise the database: `pnpm db:init`

## Google Cloud Storage authentication (for CMS uploads)
To be able to upload media files through the CMS, you need to authenticate locally. Run:  
`gcloud auth application-default login`

*NOTE*: You will need `roles/storage.objectAdmin` granted to your personal Google account to be able to upload files through the CMS from localhost.

## Development
1. Start the database: `pnpm db:start`

## Migrations
To facilitate the creation of migrations, we have a database observer that keeps track of documents that are created, updated, and deleted. It will write a change log to a local JSON file and then will let you generate migration code that will perform the necessary updates. In order to use this feature:

1. In a new console, run `pnpm db:observe`
1. And once you're ready to commit, run `pnpm db:generate-migration <optional_name>`
1. Look through the generated migration (`src/migrations`) to ensure it makes sense. Edit it on demand.

**WARNING**: The observer is in an experimental state. Always manually check the generated migration files before pushing them.
*NOTE*: You should edit what collections you like to be watched by editing `db-observer.config.json`.