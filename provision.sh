# base
apt-get update && apt-get install -y \
        git \
        gcc \
        g++ \
        make \
        build-essential \
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
    && rm -rf /var/lib/apt/lists/*

# tools
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get update && apt-get install -y \
        nodejs \
        python-dev \
        python-pip \
        python3-dev \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# vars
export GO_VERSION=1.11.5
export GO_ARCH=linux-amd64
export GO_URL=https://golang.org/dl/go${GO_VERSION}.${GO_ARCH}.tar.gz

export GOROOT=/usr/local/go
export GOPATH=/home/vagrant/go/libs
export GOOS=linux
export GOARCH=amd64

export PROTOC_PATH=/vagrant_data/software/protoc-3.6.1-linux-x86_64
export GRPC_PATH=/home/vagrant/grpc
export GRPC_VERSION=v1.18.0

# install go and mkdirs
wget -O go.tgz "$GO_URL"
tar -C /usr/local -xzf go.tgz
rm go.tgz
sudo -u vagrant mkdir -p $GOPATH
sudo -u vagrant mkdir -p $GRPC_PATH

# bashrc
echo "
# golang
export GOROOT=$GOROOT
export GOPATH=$GOPATH
export GOOS=$GOOS
export GOARCH=$GOARCH

# protoc
export PROTOC_PATH=$PROTOC_PATH

# grpc
export GRPC_PATH=$GRPC_PATH

# path
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$PROTOC_PATH/bin:$GRPC_PATH/bins/opt
" >> /home/vagrant/.bashrc

# load
source /home/vagrant/.bashrc
echo "source /home/vagrant/.bashrc" >> /home/vagrant/.bash_profile

# install grpc
git clone https://github.com/grpc/grpc.git -b $GRPC_VERSION $GRPC_PATH
cd $GRPC_PATH && git submodule update --init && make && cd -

# install grpc libs
/usr/local/go/bin/go get -u google.golang.org/grpc
/usr/local/go/bin/go get -u github.com/golang/protobuf/protoc-gen-go
/usr/local/go/bin/go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway
/usr/local/go/bin/go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger
/usr/local/go/bin/go get -u github.com/googleapis/googleapis
/usr/local/go/bin/go get -u github.com/spf13/cobra
/usr/local/go/bin/go get -u github.com/spf13/viper
/usr/local/go/bin/go get -u github.com/kardianos/govendor
/usr/local/go/bin/go get -u github.com/ddollar/forego
/usr/bin/python3 -m pip install --upgrade pip
/usr/bin/python3 -m pip install setuptools --upgrade
/usr/bin/python3 -m pip install grpcio
/usr/bin/python3 -m pip install grpcio-tools googleapis-common-protos
