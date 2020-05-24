FROM amazonlinux:2.0.20200406.0

LABEL org.label-schema.name="Amazon Kinesis Agent" \
      org.label-schema.vcs-url="https://github.com/mattiabertorello/docker-amazon-kinesis-agent" \
      org.label-schema.schema-version="1.0"

ENV AGENT_VERSION=1.1.5

RUN yum install -y curl tar gzip initscripts \
    && curl -o amazon-kinesis-agent-$AGENT_VERSION.tar.gz https://codeload.github.com/awslabs/amazon-kinesis-agent/tar.gz/$AGENT_VERSION \
    && tar xvzf amazon-kinesis-agent-$AGENT_VERSION.tar.gz \
    && cd amazon-kinesis-agent-$AGENT_VERSION \
    && ./setup --install \
    && rm -rf amazon-kinesis-agent-$AGENT_VERSION amazon-kinesis-agent-$AGENT_VERSION.tar.gz \
    && yum clean all

COPY docker-entrypoint.sh health-check.sh ./

# https://www.australtech.net/docker-healthcheck-instruction/
HEALTHCHECK --interval=1m --timeout=3s CMD ./health-check.sh

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF

ENTRYPOINT ["./docker-entrypoint.sh"]