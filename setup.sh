#!/bin/bash
# Setup script for the rails application server
set -e

export ASDF_PLATFORM=linux-amd64
export ASDF_VERSION=0.15.0
export ASDF_DATA_DIR=$HOME/.asdf

export RUBY_VERSION=3.4.7
export NODE_VERSION=
export PYTHON_VERSION=
export RUST_VERSION=
export GO_VERSION=

REQUIRED_PACKAGES=(
    g++
    gcc
    autoconf
    automake
    bison
    libc6-dev
    libffi-dev
    libgdbm-dev
    libncurses5-dev
    libtool
    libyaml-dev
    make
    pkg-config
    zlib1g-dev
    libgmp-dev
    libreadline-dev
    libssl-dev
    gnupg2
    curl
    git-core
    htop
    vim
    bash-completion
    ca-certificates
    telnet
    openssh-client
    libmagickwand-dev
    ffmpeg
    libmysqlclient-dev
    libyaml-dev
    libreadline-dev
    apache2
    libcurl4-openssl-dev
    apache2-dev
    libapr1-dev
    libaprutil1-dev
)

install_required_packages() {
    DEBIAN_FRONTEND=noninteractive \
      sudo apt-get update &&
      sudo apt-get install -y --no-install-recommends "${REQUIRED_PACKAGES[@]}"
}

install_asdf() {
    if [ ! -d "$ASDF_DATA_DIR/.git" ]; then
        git clone https://github.com/asdf-vm/asdf.git "$ASDF_DATA_DIR" --branch "v$ASDF_VERSION"
    else
        cd "$ASDF_DATA_DIR" && git fetch && git checkout "v$ASDF_VERSION"
    fi

    . "$ASDF_DATA_DIR/asdf.sh"

    echo ". \$ASDF_DATA_DIR/asdf.sh" >> "$HOME/.bashrc"
    echo "export PATH=\"\$ASDF_DATA_DIR/shims:\$PATH\"" >> "$HOME/.bashrc"
}

add_asdf_plugins() {
    # . "$ASDF_DATA_DIR/asdf.sh"
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git || true
    asdf plugin add python https://github.com/danhper/asdf-python.git || true
    asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git || true
    asdf plugin add golang https://github.com/asdf-community/asdf-golang.git || true
    asdf plugin add rust https://github.com/asdf-community/asdf-rust.git || true
}

install_languages() {
    # . "$ASDF_DATA_DIR/asdf.sh"

    [ -n "$RUBY_VERSION" ]   && asdf install ruby   "$RUBY_VERSION"   && asdf global ruby   "$RUBY_VERSION"
    [ -n "$PYTHON_VERSION" ] && asdf install python "$PYTHON_VERSION" && asdf global python "$PYTHON_VERSION"
    [ -n "$NODE_VERSION" ]   && asdf install nodejs "$NODE_VERSION"   && asdf global nodejs "$NODE_VERSION"
    [ -n "$RUST_VERSION" ]   && asdf install rust   "$RUST_VERSION"   && asdf global rust   "$RUST_VERSION"
    [ -n "$GO_VERSION" ]     && asdf install golang "$GO_VERSION"     && asdf global golang "$GO_VERSION"
}

install_yarn() {
    # . "$ASDF_DATA_DIR/asdf.sh"
    npm install -g yarn
}


install_docker() {
  sudo install -m 0755 -d /etc/apt/keyrings

  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: noble
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  # Update and install Docker CE
  DEBIAN_FRONTEND=noninteractive \
    sudo apt-get update && \
    sudo apt-get install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin
}

setup_and_install_asdf() {
    install_asdf
    add_asdf_plugins
    install_languages
}

# Main execution
install_required_packages
# install_docker
setup_and_install_asdf