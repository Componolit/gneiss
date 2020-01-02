#!/bin/sh

apt update
apt install -y expect

cd /gneiss
git submodule update --init --recursive
make -C ada-runtime

set -e

./cement test/message_client/message_client.xml . lib test

export LD_LIBRARY_PATH=build/lib
expect test/message_client/message_client.expect

