#!/bin/sh

sed -i 's@//.*archive.ubuntu.com@//mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources
sudo sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources
apt update -y --fix-missing && apt install -y --no-install-recommends ca-certificates && sed -i 's/http:/https:/g' /etc/apt/sources.list.d/ubuntu.sources
echo "******************* apt mirror set : TSINGHUA & USTC ******************"  