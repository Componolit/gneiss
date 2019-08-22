#!/bin/sh

cd /muen
git reset --hard
git fetch --all
git checkout cai
git submodule update --init components/spark_runtime/src
rm -r components/gneiss/src
ln -fs /gneiss components/gneiss/src
make -j$(nproc) SPARK_WARNINGS=continue
make -j$(nproc) SPARK_WARNINGS=continue COMPONENTS=spark_runtime
set -e
make -j$(nproc) SPARK_WARNINGS=continue RTS_DIR=/muen/components/spark_runtime/obj/ AGGREGATE=gneiss/gneiss.gpr COMPONENTS_BUILD="sdump cai_hello_world cai_timer cai_block_client cai_block_server cai_block_proxy cai_test cai_rom"
