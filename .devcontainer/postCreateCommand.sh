#!/bin/zsh

function pull() {
  local PATH="$1"
  if [ ! "../assets/$PATH" ]; then
    git lfs pull --include=$PATH
    if [[ "$PATH" == *"rmvpe"* ]]; then
      mv $PATH ../assets/rmvpe/$PATH
    else
      mv $PATH ../assets/$PATH
    fi
  fi
}

export GIT_CLONE_PROTECTION_ACTIVE=false
export GIT_LFS_SKIP_SMUDGE=1
  
mkdir -p assets/rmvpe
  
git clone --depth 1 https://huggingface.co/lj1995/VoiceConversionWebUI VoiceConversionWebUI
cd VoiceConversionWebUI
git config advice.detachedHead false
git checkout $SHA256_COMMIT_HASH

unset GIT_LFS_SKIP_SMUDGE
unset GIT_CLONE_PROTECTION_ACTIVE

pull "hubert_base.pt"
pull "pretrained"
pull "uvr5_weights"
pull "rmvpe.pt"
pull "rmvpe.onnx"

cd ..
rm -rf VoiceConversionWebUI
poetry install --no-interaction --no-root
poetry cache clear --all .