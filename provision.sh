# automatic
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_RELEASE=bullseye
export MY_USER=vagrant

# sources
echo "
deb http://deb.debian.org/debian ${DEBIAN_RELEASE} main contrib non-free
deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE} main contrib non-free

deb http://deb.debian.org/debian-security/ ${DEBIAN_RELEASE}-security main contrib non-free
deb-src http://deb.debian.org/debian-security/ ${DEBIAN_RELEASE}-security main contrib non-free

deb http://deb.debian.org/debian ${DEBIAN_RELEASE}-updates main contrib non-free
deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE}-updates main contrib non-free
" > /etc/apt/sources.list

echo "
deb http://deb.debian.org/debian ${DEBIAN_RELEASE}-backports main contrib non-free
deb-src http://deb.debian.org/debian ${DEBIAN_RELEASE}-backports main contrib non-free
" | tee /etc/apt/sources.list.d/backports.list

# base
apt-get update && apt-get install -y \
        git \
        gcc \
        g++ \
        gdb \
        make \
        build-essential \
        openssl \
        libssl-dev \
        libc6-dev \
        autoconf \
        libtool \
        pkg-config \
        libgflags-dev \
        libgtest-dev \
        zlib1g-dev \
        clang \
        libc++-dev \
        software-properties-common \
        libjansson-dev \
        net-tools \
        curl \
        wget \
        resolvconf \
        tmux \
        vim \
        unzip \
        p7zip \
    && rm -rf /var/lib/apt/lists/*

# timezone
export TZ=UTC
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# dns
echo "
nameserver 1.1.1.1
nameserver 1.0.0.1
" | tee -a /etc/resolvconf/resolv.conf.d/head
resolvconf --enable-updates
resolvconf -u

# cmake
export CMAKE_VERSION=3.18.4
wget -q -O cmake-linux.sh http://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh
sh cmake-linux.sh -- --skip-license --prefix=/usr
rm cmake-linux.sh

# 3rd sources
curl -sL https://deb.nodesource.com/setup_16.x | bash -
curl -sS https://deb.troglobit.com/pubkey.gpg | apt-key add -
echo "deb [arch=amd64] https://deb.troglobit.com/debian stable main" | tee /etc/apt/sources.list.d/troglobit.list

# install
apt-get update && apt-get install -y \
        python3-dev \
        python3-pip \
        openjdk-11-jdk \
        nodejs \
        jq \
        sqlite3 \
        nasm \
        strace \
        tcpdump \
        nmap \
        netcat \
        nemesis \
        nginx \
        nginx-extras \
        apache2-utils \
        libcurl4 \
        redis-tools \
        certbot \
        kafkacat \
        mit-scheme \
        mosquitto-clients \
    && rm -rf /var/lib/apt/lists/*

# docker
wget -qO- https://get.docker.com/ | sh
usermod -a -G docker ${MY_USER}
service docker start

# docker-compose
export DOCKER_COMPOSE_VERSION=1.29.2
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# vars
export GO_VERSION=1.18.5
export GO_ARCH=linux-amd64
export GO_URL=https://golang.org/dl/go${GO_VERSION}.${GO_ARCH}.tar.gz
export GOROOT=/usr/local/go
export GOPATH=/home/${MY_USER}/go/libs
export GOOS=linux
export GOARCH=amd64
export GRPC_VERSION=v1.48.1
export GRPC_PATH=/home/${MY_USER}/grpc
export GRPC_INSTALL_DIR=/home/${MY_USER}/.grpc
export RUST_PATH=/home/${MY_USER}/.cargo

# install go and mkdirs
wget -O go.tgz "$GO_URL"
tar -C /usr/local -xzf go.tgz
rm go.tgz
sudo -u ${MY_USER} mkdir -p $GOPATH
sudo -u ${MY_USER} mkdir -p $GRPC_PATH
sudo -u ${MY_USER} mkdir -p $GRPC_INSTALL_DIR

# install avro
export AVRO_VERSION=1.11.0
export AVRO_PREFIX=/home/vagrant/avro
mkdir -p $AVRO_PREFIX/bin
wget https://downloads.apache.org/avro/avro-${AVRO_VERSION}/avro-src-${AVRO_VERSION}.tar.gz
tar -xzvf avro-src-${AVRO_VERSION}.tar.gz
pushd avro-src-${AVRO_VERSION}/lang/c
mkdir build
pushd build
cmake .. \
        -DCMAKE_INSTALL_PREFIX=$AVRO_PREFIX \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo
make
make test
make install
popd
popd

# install libsodium
export LIBSODIUM_VERSION=1.0.18
curl -fsSL https://github.com/jedisct1/libsodium/archive/${LIBSODIUM_VERSION}.tar.gz | tar -xz
pushd libsodium-${LIBSODIUM_VERSION}
./autogen.sh
./configure
make
make install
popd

# install julia
export JULIA_VERSION=1.8.0
wget https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz
chown -R root:root julia-${JULIA_VERSION}
sudo mv julia-${JULIA_VERSION} /opt/
sudo ln -s /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia
sudo -u ${MY_USER} mkdir -p /home/${MY_USER}/.julia/

# install typescript
npm install -g typescript

# bashrc
echo "
# custom
export TZ=$TZ
alias netstat='sudo netstat'
alias docker='sudo docker'

# golang
export GOROOT=$GOROOT
export GOPATH=$GOPATH
export GOOS=$GOOS
export GOARCH=$GOARCH

# protoc
export PROTOC_PATH=$PROTOC_PATH

# grpc
export GRPC_PATH=$GRPC_PATH

# rust
export RUST_PATH=$RUST_PATH

# libsodium
export SODIUM_LIB_DIR=/usr/local/lib
export LD_LIBRARY_PATH=/usr/local/lib

# path
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$GRPC_INSTALL_DIR/bin:$AVRO_PREFIX/bin:$RUST_PATH/bin
" >> /home/${MY_USER}/.bashrc

# load
source /home/${MY_USER}/.bashrc
echo "source /home/${MY_USER}/.bashrc" >> /home/${MY_USER}/.bash_profile
chown ${MY_USER}:${MY_USER} /home/${MY_USER}/.bash_profile

# install grpc
git clone --recurse-submodules -b $GRPC_VERSION https://github.com/grpc/grpc.git $GRPC_PATH
pushd $GRPC_PATH
mkdir -p cmake/build
pushd cmake/build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DgRPC_INSTALL=ON \
  -DgRPC_BUILD_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX=$GRPC_INSTALL_DIR \
  ../..
make -j4
make install
popd
popd

# update python base libs
/usr/bin/python3 -m pip install pip --upgrade
/usr/bin/python3 -m pip install setuptools --upgrade
/usr/bin/python3 -m pip install virtualenv --upgrade
/usr/bin/python3 -m pip install pipenv --upgrade
/usr/bin/python3 -m pip install supervisor --upgrade
/usr/bin/python3 -m pip install avro --upgrade

# ${MY_USER} as owner
chown ${MY_USER}:${MY_USER} -R $GOPATH
chown ${MY_USER}:${MY_USER} -R $PROTOC_PATH
chown ${MY_USER}:${MY_USER} -R $GRPC_PATH
sudo -u ${MY_USER} mkdir -p /home/${MY_USER}/.cache

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# cleanup
apt-get autoclean -y && apt-get autoremove -y
