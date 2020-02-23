# base
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -y \
        git \
        gcc \
        g++ \
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
        clang \
        libc++-dev \
        software-properties-common \
        curl \
        wget \
        resolvconf \
    && rm -rf /var/lib/apt/lists/*

# timezone
export TZ=UTC
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# dns
echo "
nameserver 8.8.4.4
nameserver 8.8.8.8
" >> /etc/resolvconf/resolv.conf.d/head
service resolvconf restart

# tools sources
add-apt-repository -y ppa:certbot/certbot
apt-add-repository -y ppa:mosquitto-dev/mosquitto-ppa
curl -sL https://deb.nodesource.com/setup_12.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb

# install
apt-get update && apt-get install -y \
        libpython2.7 \
        libpython2.7-dev \
        python-dev \
        python-pip \
        python3-dev \
        python3-pip \
        python3.7 \
        python3.7-dev \
        python3.8 \
        python3.8-dev \
        nodejs \
        yarn \
        tmux \
        vim \
        sqlite3 \
        nginx \
        nginx-extras \
        apache2-utils \
        libcurl3 \
        redis-tools \
        unzip \
        p7zip \
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
usermod -a -G docker ubuntu
service docker start

# vars
export GO_VERSION=1.14
export GO_ARCH=linux-amd64
export GO_URL=https://golang.org/dl/go${GO_VERSION}.${GO_ARCH}.tar.gz

export GOROOT=/usr/local/go
export GOPATH=/home/ubuntu/go/libs
export GOOS=linux
export GOARCH=amd64

export PROTOC_VERSION=3.11.2
export GRPC_VERSION=v1.27.2
export SWIFT_VERSION=5.1.4
export PROTOC_PATH=/home/ubuntu/software/protoc-${PROTOC_VERSION}-linux-x86_64
export GRPC_PATH=/home/ubuntu/grpc
export RUST_PATH=/home/ubuntu/.cargo
export SWIFT_PATH=/usr/share/swift/usr

# protoc
sudo -u ubuntu mkdir -p $PROTOC_PATH
cd $PROTOC_PATH
wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip
unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip
cd -

# install go and mkdirs
wget -O go.tgz "$GO_URL"
tar -C /usr/local -xzf go.tgz
rm go.tgz
sudo -u ubuntu mkdir -p $GOPATH
sudo -u ubuntu mkdir -p $GRPC_PATH

# install swift
wget https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1804/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04.tar.gz
tar xzf swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04.tar.gz
sudo mv swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04 /usr/share/swift

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

# swift
export SWIFT_PATH=$SWIFT_PATH

# path
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$PROTOC_PATH/bin:$GRPC_PATH/bins/opt:$RUST_PATH/bin:$SWIFT_PATH/bin
" >> /home/ubuntu/.bashrc

# load
source /home/ubuntu/.bashrc
echo "source /home/ubuntu/.bashrc" >> /home/ubuntu/.bash_profile
chown ubuntu:ubuntu /home/ubuntu/.bash_profile

# install grpc
git clone https://github.com/grpc/grpc.git -b $GRPC_VERSION $GRPC_PATH
cd $GRPC_PATH && git submodule update --init && make && cd -

# install grpc libs
/usr/local/go/bin/go get -u google.golang.org/grpc
/usr/local/go/bin/go get -u github.com/golang/protobuf/protoc-gen-go
/usr/local/go/bin/go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway
/usr/local/go/bin/go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger
/usr/local/go/bin/go get -u github.com/googleapis/googleapis
/usr/local/go/bin/go get -u github.com/ddollar/forego
/usr/bin/python3 -m pip install pip --upgrade
/usr/bin/python3 -m pip install setuptools --upgrade
/usr/bin/python3 -m pip install virtualenv --upgrade
/usr/bin/python3 -m pip install pipenv --upgrade
/usr/bin/python3 -m pip install git+https://github.com/Supervisor/supervisor && mkdir -p /var/log/supervisor
/usr/bin/python3 -m pip install grpcio
/usr/bin/python3 -m pip install grpcio-tools googleapis-common-protos

# ubuntu as owner
chown ubuntu:ubuntu -R $GOPATH
chown ubuntu:ubuntu -R $PROTOC_PATH
chown ubuntu:ubuntu -R $GRPC_PATH
chown ubuntu:ubuntu -R /home/ubuntu/.cache

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# cleanup
apt-get autoclean && apt-get autoremove
