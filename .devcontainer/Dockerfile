FROM mcr.microsoft.com/devcontainers/python:dev-3.10-bookworm

RUN \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y libsndfile1 libsndfile1-dev

USER vscode
WORKDIR /home/vscode/