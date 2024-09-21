# Google Cloud Platform infrastructure

## Overview

This infrastructure is based on Google Cloud Run services hosting the website (Node.js service), with load balancing and CDN set up.
There's also a MongoDB Atlas for the CMS to use as a database.

## Prerequisites

You need to configure an `allUsersIngress` tag and a relevant DRS policy in your Google Cloud Platform's IAM to allow `allUsers` public access to Google Cloud Run. You then need to set that tag's valid ID in a `gcp_all_users_ingress_tag_value_id` variable in Terraform Cloud. That value has a format of `tagValues/XXXXXXXXXXXXXXX`.
