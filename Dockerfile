FROM alpine/git:latest AS assets
ARG SHA256_COMMIT_HASH=88e42f0cb3662ddc0dd263a4814206ce96d53214
ENV GIT_CLONE_PROTECTION_ACTIVE=false
ENV GIT_LFS_SKIP_SMUDGE=1

WORKDIR /app
RUN git clone --progress --depth 1 https://huggingface.co/lj1995/VoiceConversionWebUI
WORKDIR /app/VoiceConversionWebUI
RUN git config advice.detachedHead false
RUN git checkout $SHA256_COMMIT_HASH
RUN unset GIT_LFS_SKIP_SMUDGE
RUN unset GIT_CLONE_PROTECTION_ACTIVE
RUN git lfs pull --include="hubert_base.pt"
RUN git lfs pull --include="pretrained"
RUN git lfs pull --include="uvr5_weights"
RUN git lfs pull --include="rmvpe.pt"
RUN git lfs pull --include="rmvpe.onnx"

FROM mcr.microsoft.com/devcontainers/python:dev-3.10-bookworm
ENV PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

RUN \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y git libsndfile1 libsndfile1-dev

WORKDIR /home/vscode/app/
COPY --from=assets /app/VoiceConversionWebUI/pretrained assets/pretrained
COPY --from=assets /app/VoiceConversionWebUI/uvr5_weights assets/uvr5_weights
COPY --from=assets /app/VoiceConversionWebUI/hubert_base.pt assets/hubert_base.pt
COPY --from=assets /app/VoiceConversionWebUI/rmvpe.pt assets/rmvpe/rmvpe.pt
COPY --from=assets /app/VoiceConversionWebUI/rmvpe.onnx assets/rmvpe/rmvpe.onnx
COPY ./pyproject.toml .
COPY ./rvc ./rvc

RUN pip install poetry==1.7.1
RUN poetry install --no-interaction --no-root -vvv
RUN poetry cache clear --all .
CMD [ "poetry", "run", "poe", "rvc-api" ]
