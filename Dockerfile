FROM python:3.8.0b2-buster

RUN pip3 install --no-cache --upgrade awscli==1.16.188 && \
  apt-get update -y && \
  apt-get install -y --no-install-recommends curl wget unzip git sudo jq && \
  rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://releases.hashicorp.com/terraform/0.12.1/terraform_0.12.1_linux_amd64.zip \
  && unzip terraform_0.12.1_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_0.12.1_linux_amd64.zip

WORKDIR /userdata
RUN mkdir .secrets
RUN mkdir .terraform

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
