#!/bin/bash

# Set default REPO to lede if not set
REPO="${REPO:-lede}"

echo "Using REPO: $REPO"

case "$REPO" in
  immortalwrt)
    echo "Setting up immortalwrt environment..."
    sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
      bzip2 ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex gawk gettext gcc-multilib \
      g++-multilib git gnutls-dev gperf haveged help2man intltool lib32gcc-s1 libc6-dev-i386 libelf-dev \
      libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libpython3-dev \
      libreadline-dev libssl-dev libtool libyaml-dev libz-dev lld llvm lrzsz mkisofs msmtp nano \
      ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip python3-ply python3-docutils \
      python3-pyelftools qemu-utils re2c rsync scons squashfs-tools subversion swig texinfo uglifyjs \
      upx-ucl unzip vim wget xmlto xxd zlib1g-dev zstd
    echo "immortalwrt environment setup completed."
    ;;
  lede)
    echo "Setting up lede environment..."
    sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
      bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
      genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
      libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
      libreadline-dev libssl-dev libtool llvm lrzsz libnsl-dev ninja-build p7zip p7zip-full patch pkgconf \
      python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
      swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev
    echo "lede environment setup completed."
    ;;
  *)
    echo "Error: Unknown REPO value '$REPO'."
    echo "REPO must be either 'immortalwrt' or 'lede'."
    exit 1
    ;;
esac