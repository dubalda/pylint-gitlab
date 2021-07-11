FROM debian:10.10-slim

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends -y python3-pip python3-setuptools && \
    pip3 install pylint-gitlab && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
