# Locations Poller

## Purpose

Regularly queries Sierra for mapping of location codes to urls, and stores this mapping in S3

## Running locally

```
rvm use
bundle install
```

To test an event locally:

```
sam local invoke --region us-east-1 --template sam.local.yml --profile nypl-digital-dev --event event.json
```

## Contributing


This repo follows a [PRS-Target-Master Git Workflow](https://github.com/NYPL/engineering-general/blob/a19c78b028148465139799f09732e7eb10115eef/standards/git-workflow.md#prs-target-master-merge-to-deployment-branches)

## Testing

`bundle exec rspec`

## Deployment

CI/CD is configured in `.travis.yml` for the following branches:

- `qa`
- `production`
