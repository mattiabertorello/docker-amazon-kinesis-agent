#!/usr/bin/env bash
set -x

# https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86
# SIGTERM-handler
term_handler() {
  /etc/init.d/aws-kinesis-agent stop
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM SIGINT

# run application
/etc/init.d/aws-kinesis-agent start

# get the agent pid. Example: `aws-kinesis-agent (pid  14) is running...`
agent_pid=$(/etc/init.d/aws-kinesis-agent status | tr -dc '0-9')

# wait forever
while true
do
  # tail the stout and sterr of the agent process
  tail -qF "/proc/$agent_pid/fd/1" "/proc/$agent_pid/fd/2"  & wait ${!}
done