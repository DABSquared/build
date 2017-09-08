FROM openjdk:8-alpine

LABEL maintainer "dbrooks@dabsquared.com"

ENV S3_TMP /tmp/s3cmd.zip
ENV S3_ZIP /tmp/s3cmd-master
ENV RDS_TMP /tmp/RDSCLi.zip
ENV RDS_VERSION 1.19.004
ENV AWS_RDS_HOME /usr/local/RDSCli-${RDS_VERSION}
ENV PATH ${PATH}:${AWS_RDS_HOME}/bin:${JAVA_HOME}/bin:${AWS_RDS_HOME}/bin
ENV PAGER more

WORKDIR /tmp

RUN apk --no-cache add \
      zip \
      bash \
      bash-completion \
      groff \
      less \
      curl \
      jq \
      py-pip \
      python \
      openssh &&\
    pip install --upgrade \
      awscli \
      pip \
      awsebcli \
      python-dateutil &&\
    ln -s /usr/bin/aws_bash_completer /etc/profile.d/aws_bash_completer.sh &&\
    curl -sSL --output ${S3_TMP} https://github.com/s3tools/s3cmd/archive/master.zip &&\
    curl -sSL --output ${RDS_TMP} http://s3.amazonaws.com/rds-downloads/RDSCli.zip &&\
    unzip -q ${S3_TMP} -d /tmp &&\
    unzip -q ${RDS_TMP} -d /tmp &&\
    mv ${S3_ZIP}/S3 ${S3_ZIP}/s3cmd /usr/bin/ &&\
    mv /tmp/RDSCli-${RDS_VERSION} /usr/local/ &&\
    rm -rf /tmp/* &&\
    mkdir ~/.aws &&\
    chmod 700 ~/.aws

# Expose volume for adding credentials
VOLUME ["~/.aws"]

ENV TERRAFORM_VERSION=0.10.4
ENV TERRAFORM_SHA256SUM=cff83f669d0e4ac315e792a57659d5aae8ea1fcfdca6931c7cc4679b4e6c60e3

RUN apk add --update git curl openssh && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

CMD ["/bin/bash", "--login"]
