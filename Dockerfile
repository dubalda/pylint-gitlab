FROM debian:10.10-slim

RUN mkdir -p public/badges public/lint && \
    apt update && \
    apt install -y python3-pip && \
    pip3 install pylint-gitlab
