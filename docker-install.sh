#!/bin/bash

set -e

echo "检测操作系统..."

OS=""
VERSION_ID=""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION_ID=$VERSION_ID
else
    echo "无法检测操作系统，退出。"
    exit 1
fi

install_docker_debian_ubuntu() {
    echo "更新软件包索引..."
    sudo apt-get update

    echo "安装依赖包..."
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    echo "添加Docker官方GPG密钥..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/${OS}/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo "设置Docker仓库..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS} \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "更新软件包索引..."
    sudo apt-get update

    echo "安装Docker Engine及相关组件..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "启动并设置Docker开机自启..."
    sudo systemctl start docker
    sudo systemctl enable docker
}

install_docker_almalinux() {
    echo "更新系统软件包..."
    sudo dnf -y update

    echo "安装依赖软件包..."
    sudo dnf -y install dnf-utils device-mapper-persistent-data lvm2

    echo "添加Docker官方仓库..."
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    echo "安装Docker Engine及相关组件..."
    sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "启动并设置Docker开机自启..."
    sudo systemctl start docker
    sudo systemctl enable docker
}

case "$OS" in
    ubuntu|debian)
        echo "检测到系统为 $OS $VERSION_ID"
        install_docker_debian_ubuntu
        ;;
    almalinux|centos)
        echo "检测到系统为 $OS $VERSION_ID"
        install_docker_almalinux
        ;;
    *)
        echo "不支持的操作系统：$OS"
        exit 1
        ;;
esac

echo "验证Docker安装..."
docker --version

echo "安装完成！Docker已启动并设置为开机自启。"
echo "你可以运行 'sudo docker run hello-world' 测试Docker是否正常运行。"
