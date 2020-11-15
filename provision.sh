# base
export DEBIAN_FRONTEND=noninteractive
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
        clang \
        libc++-dev \
        software-properties-common \
        curl \
        wget \
        resolvconf \
    && rm -rf /var/lib/apt/lists/*

# gnu
add-apt-repository -y ppa:ubuntu-toolchain-r/test
apt-get update && apt-get install -y gcc-7 g++-7 gcc-8 g++-8 gcc-9 g++-9 gcc-10 g++-10
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 10
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10

# llvm
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh 11
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-6.0 6
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-6.0 6
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-11 11
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-11 11

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

# tools sources
add-apt-repository -y ppa:certbot/certbot
apt-add-repository -y ppa:mosquitto-dev/mosquitto-ppa
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
usermod -a -G docker vagrant
service docker start

# vars
export GO_VERSION=1.15.5
export GO_ARCH=linux-amd64
export GO_URL=https://golang.org/dl/go${GO_VERSION}.${GO_ARCH}.tar.gz

export GOROOT=/usr/local/go
export GOPATH=/home/vagrant/go/libs
export GOOS=linux
export GOARCH=amd64

export PROTOC_VERSION=3.13.0
export GRPC_VERSION=v1.33.2
export JULIA_VERSION=1.5.3
export SWIFT_VERSION=5.3.1
export PROTOC_PATH=/home/ubuntu/software/protoc-${PROTOC_VERSION}-linux-x86_64
export GRPC_PATH=/home/ubuntu/grpc
export RUST_PATH=/home/vagrant/.cargo
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
sudo -u vagrant mkdir -p $GOPATH
sudo -u vagrant mkdir -p $GRPC_PATH

# install julia
wget https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz
chown -R root:root julia-${JULIA_VERSION}
sudo mv julia-${JULIA_VERSION} /opt/
sudo ln -s /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia
sudo -u vagrant mkdir -p /home/vagrant/.julia/

# install swift
wget https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1804/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04.tar.gz
tar xzf swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04.tar.gz
sudo mv swift-${SWIFT_VERSION}-RELEASE-ubuntu18.04 /usr/share/swift

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

# swift
export SWIFT_PATH=$SWIFT_PATH

# path
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$PROTOC_PATH/bin:$GRPC_PATH/bins/opt:$RUST_PATH/bin:$SWIFT_PATH/bin
" >> /home/vagrant/.bashrc

# load
source /home/vagrant/.bashrc
echo "source /home/vagrant/.bashrc" >> /home/vagrant/.bash_profile
chown vagrant:vagrant /home/vagrant/.bash_profile

# install grpc
git clone https://github.com/grpc/grpc.git -b $GRPC_VERSION $GRPC_PATH
cd $GRPC_PATH && git submodule update --init && make && cd -

# update python base libs
/usr/bin/python3 -m pip install pip --upgrade
/usr/bin/python3 -m pip install setuptools --upgrade
/usr/bin/python3 -m pip install virtualenv --upgrade
/usr/bin/python3 -m pip install pipenv --upgrade
/usr/bin/python3 -m pip install git+https://github.com/Supervisor/supervisor.git@4.2.1 && mkdir -p /var/log/supervisor

# ubuntu as owner
chown vagrant:vagrant -R $GOPATH
chown vagrant:vagrant -R $PROTOC_PATH
chown vagrant:vagrant -R $GRPC_PATH
chown vagrant:vagrant -R /home/vagrant/.cache

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# cleanup
apt-get autoclean -y && apt-get autoremove -y
