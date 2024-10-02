# Local development

## Setup
Install dependencies by running `pnpm i`

## Google Cloud Storage authentication (for CMS uploads)
To be able to upload media files through the CMS, you need to authenticate locally. Run:  
`gcloud auth application-default login`

*NOTE*: You will need `roles/storage.objectAdmin` granted to your personal Google account to be able to upload files through the CMS from localhost.

## Development
Run:  
`pnpm dev`