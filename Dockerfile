FROM alpine/git:latest AS assets
ARG SHA256_COMMIT_HASH=88e42f0cb3662ddc0dd263a4814206ce96d53214
ENV GIT_CLONE_PROTECTION_ACTIVE=false
ENV GIT_LFS_SKIP_SMUDGE=1

WORKDIR /app
RUN git clone --progress --depth 10 https://huggingface.co/lj1995/VoiceConversionWebUI
WORKDIR /app/VoiceConversionWebUI
RUN git checkout $SHA256_COMMIT_HASH

FROM python:3.10.14-bullseye AS app

RUN \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y git libsndfile1 libsndfile1-dev
WORKDIR /app
COPY --from=assets /app/VoiceConversionWebUI/pretrained /app/assets/pretrained
COPY --from=assets /app/VoiceConversionWebUI/uvr5_weights /app/assets/uvr5_weights
COPY --from=assets /app/VoiceConversionWebUI/hubert_base.pt /app/assets/hubert_base.pt
COPY --from=assets /app/VoiceConversionWebUI/hubert_base.pt /app/assets/rmvpe/rmvpe.pt
COPY --from=assets /app/VoiceConversionWebUI/hubert_base.pt /app/assets/rmvpe/rmvpe.onnx
COPY ./pyproject.toml .
COPY ./rvc ./rvc

RUN pip install poetry==1.7.1
RUN poetry install --no-interaction --no-root
RUN poetry cache clear --all .
CMD [ "poetry", "run", "poe", "rvc-api" ]
