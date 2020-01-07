#!/bin/sh

apt update
apt install -y expect python3 python3-pip

cd /gneiss
git submodule update --init --recursive
pip3 install -e tool/RecordFlux
make -C ada-runtime

set -e

./cement test/message_client/message_client.xml . lib test
./cement test/hello_world/hello_world.xml . lib test

export LD_LIBRARY_PATH=build/lib
expect test/message_client/message_client.expect
expect test/hello_world/hello_world.expect

