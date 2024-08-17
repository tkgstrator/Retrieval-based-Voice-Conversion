#!/bin/zsh

if [ ! -d "assets/rmvpe" ]; then
  git clone https://huggingface.co/lj1995/VoiceConversionWebUI VoiceConversionWebUI
  cd VoiceConversionWebUI
  git checkout $SHA256_COMMIT_HASH
  
  mkdir -p ../assets/rmvpe
  mv pretrained ../assets/
  mv uvr5_weights ../assets/
  mv rmvpe.pt ../assets/rmvpe/rmvpe.pt
  mv rmvpe.onnx ../assets/rmvpe/rmvpe.onnx
  mv hubert_base.pt ../assets/hubert_base.pt
  
  rm -rf ../VoiceConversionWebUI
  poetry install --no-interaction --no-root
  poetry cache clear --all .
fi