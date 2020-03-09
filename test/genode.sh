#!/bin/sh

set -e
cd /genode
git remote add jklmnn https://github.com/jklmnn/genode.git
git fetch jklmnn
git checkout b0d01103e20981d64a81b8494359c9606017e4bf
git clone https://github.com/Componolit/genode-componolit.git /genode/repos/componolit
cd /genode/repos/componolit
git checkout cbb52b2139cfaf5afcccc1ec5c64a01fafe0250a
rm -rf /genode/repos/componolit/modules/gneiss
ln -fs /gneiss /genode/repos/componolit/modules/gneiss
git submodule update --init --recursive modules/basalt
/genode/tool/create_builddir x86_64
cd /genode/build/x86_64
sed -i "s/^#REPOS/REPOS/g;s/^#MAKE.*$/MAKE += -j$(nproc)/g" etc/build.conf
echo 'REPOSITORIES += $(GENODE_DIR)/repos/componolit' >> etc/build.conf
/genode/tool/ports/prepare_port ada-runtime
make KERNEL=linux BOARD=linux run/gneiss/hello_world
make KERNEL=linux BOARD=linux run/gneiss/rom
make KERNEL=linux BOARD=linux run/gneiss/timer
make KERNEL=linux BOARD=linux run/gneiss/block_client
make KERNEL=linux BOARD=linux run/gneiss/block_server
make KERNEL=linux BOARD=linux run/gneiss/block_proxy
make KERNEL=linux BOARD=linux run/gneiss/log_proxy
make KERNEL=linux BOARD=linux run/gneiss/memory
make KERNEL=linux BOARD=linux run/gneiss/message
make KERNEL=linux BOARD=linux run/gneiss/memory_cpp
make KERNEL=linux BOARD=linux run/gneiss/message_cpp
