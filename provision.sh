# automatic
export DEBIAN_FRONTEND=noninteractive
export MY_USER=vagrant

# sources
echo "
deb http://deb.debian.org/debian buster main contrib non-free
deb-src http://deb.debian.org/debian buster main contrib non-free

deb http://deb.debian.org/debian-security/ buster/updates main contrib non-free
deb-src http://deb.debian.org/debian-security/ buster/updates main contrib non-free

deb http://deb.debian.org/debian buster-updates main contrib non-free
deb-src http://deb.debian.org/debian buster-updates main contrib non-free
" > /etc/apt/sources.list

echo "
deb http://deb.debian.org/debian buster-backports main contrib non-free
deb-src http://deb.debian.org/debian buster-backports main contrib non-free
" | tee /etc/apt/sources.list.d/backports.list

# base
apt-get update && apt-get install -y \
        git \
        gcc \
        g++ \
        make \
        cmake \
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
        emacs \
        emacs24 \
        unzip \
        p7zip \
    && rm -rf /var/lib/apt/lists/*

# timezone
export TZ=UTC
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# dns
echo "
nameserver 8.8.4.4
nameserver 8.8.8.8
" | tee /etc/resolvconf/resolv.conf.d/head
resolvconf --enable-updates
resolvconf -u

# llvm
# wget https://apt.llvm.org/llvm.sh
# chmod +x llvm.sh
# ./llvm.sh

# 3rd sources
curl -sL https://deb.nodesource.com/setup_14.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && dpkg -i erlang-solutions_2.0_all.deb

# install
apt-get update && apt-get install -y \
        libpython2.7 \
        libpython2.7-dev \
        python-dev \
        python-pip \
        python3-dev \
        python3-pip \
        nodejs \
        yarn \
        sqlite3 \
        nginx \
        nginx-extras \
        apache2-utils \
        libcurl4 \
        redis-tools \
        certbot \
        python-certbot-nginx \
        esl-erlang \
        elixir \
        mit-scheme \
        mosquitto \
        mosquitto-clients \
        mosquitto-dev \
    && rm -rf /var/lib/apt/lists/*

# docker
wget -qO- https://get.docker.com/ | sh
usermod -a -G docker ${MY_USER}
service docker start

# docker-compose
export DOCKER_COMPOSE_VERSION=1.28.0
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# vars
export GO_VERSION=1.16
export GO_ARCH=linux-amd64
export GO_URL=https://golang.org/dl/go${GO_VERSION}.${GO_ARCH}.tar.gz

export GOROOT=/usr/local/go
export GOPATH=/home/${MY_USER}/go/libs
export GOOS=linux
export GOARCH=amd64

export PROTOC_VERSION=3.13.0
export GRPC_VERSION=v1.34.1
export JULIA_VERSION=1.5.3
export PROTOC_PATH=/home/${MY_USER}/software/protoc-${PROTOC_VERSION}-linux-x86_64
export GRPC_PATH=/home/${MY_USER}/grpc
export RUST_PATH=/home/${MY_USER}/.cargo

# protoc
sudo -u ${MY_USER} mkdir -p $PROTOC_PATH
cd $PROTOC_PATH
wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip
cd -

# install go and mkdirs
wget -O go.tgz "$GO_URL"
tar -C /usr/local -xzf go.tgz
rm go.tgz
sudo -u ${MY_USER} mkdir -p $GOPATH
sudo -u ${MY_USER} mkdir -p $GRPC_PATH

# install avro
export AVRO_PREFIX=/home/vagrant/avro
mkdir -p $AVRO_PREFIX/bin
wget https://downloads.apache.org/avro/avro-1.10.1/avro-src-1.10.1.tar.gz
tar -xzvf avro-src-1.10.1.tar.gz
# pushd avro-src-1.10.1
# mkdir build
# pushd build
# cmake .. \
#         -DCMAKE_INSTALL_PREFIX=$AVRO_PREFIX \
#         -DCMAKE_BUILD_TYPE=RelWithDebInfo
# make
# make test
# make install
# popd
# popd

# install julia
wget https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
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

# path
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$PROTOC_PATH/bin:$GRPC_PATH/bins/opt:$RUST_PATH/bin:$AVRO_PREFIX/bin
" >> /home/${MY_USER}/.bashrc

# load
source /home/${MY_USER}/.bashrc
echo "source /home/${MY_USER}/.bashrc" >> /home/${MY_USER}/.bash_profile
chown ${MY_USER}:${MY_USER} /home/${MY_USER}/.bash_profile

# install grpc
git clone https://github.com/grpc/grpc.git -b $GRPC_VERSION $GRPC_PATH
cd $GRPC_PATH && git submodule update --init && make && cd -

# go grpc
export GO111MODULE=on
/usr/local/go/bin/go get -u google.golang.org/grpc
/usr/local/go/bin/go get -u google.golang.org/protobuf/cmd/protoc-gen-go
/usr/local/go/bin/go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc
/usr/local/go/bin/go get -u github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
/usr/local/go/bin/go get -u github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
/usr/local/go/bin/go get -u github.com/googleapis/googleapis

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
