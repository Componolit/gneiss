#!/bin/sh

cd /muen
git reset --hard
git checkout cai
git submodule update --init components/spark_runtime/src
rm -r components/cai/src
ln -fs /ada-interfaces components/cai/src
make -j$(nproc) SPARK_WARNINGS=continue
make -j$(nproc) SPARK_WARNINGS=continue COMPONENTS=spark_runtime
set -e
make -j$(nproc) SPARK_WARNINGS=continue RTS_DIR=/muen/components/spark_runtime/obj/ AGGREGATE=cai/ada_interface.gpr COMPONENTS_BUILD="sdump"
