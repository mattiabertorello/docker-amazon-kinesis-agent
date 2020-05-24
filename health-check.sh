#!/usr/bin/env bash

agent_status="$(/etc/init.d/aws-kinesis-agent status)"
echo "$agent_status"
if [[ "$agent_status" == *"running"* ]]; then
  exit 0
fi
exit 1