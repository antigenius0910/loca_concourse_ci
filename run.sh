#!/bin/bash

# fly --target example login --team-name main --concourse-url http://localhost:8080

fly -t example set-pipeline -p test2 -c test-pipeline.yml -l ~/.ssh/credentials_zabbix.yml && \
fly -t example unpause-pipeline -p test2 && \
fly -t example trigger-job -j test2/job-test-build && \
fly -t example watch -j test2/job-test-build

# fly -t example hijack -j test2/job-test-build
# fly -t example destroy-pipeline -p test2
