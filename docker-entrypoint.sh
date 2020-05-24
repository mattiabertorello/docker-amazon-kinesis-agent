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

agent_log=/var/log/aws-kinesis-agent/aws-kinesis-agent.log
while [ ! -f "$agent_log" ]
do
  sleep 0.5
done

# wait forever
while true
do
  tail -n +1 -f $agent_log & wait ${!}
done