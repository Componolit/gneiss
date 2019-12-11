#!/bin/sh

apt update
apt install -y expect

cd /gneiss
git submodule update --init --recursive
make -C ada-runtime

set -e

gprbuild -P gneiss.gpr -XKIND=static -XPLATFORM=linux -XTEST=init
gprbuild -P gneiss.gpr -XKIND=static -XPLATFORM=linux -XTEST=message_client
gprbuild -P gneiss.gpr -XKIND=static -XPLATFORM=linux -XTEST=message_server

export LD_LIBRARY_PATH=build/libcomponents:ada-runtime/obj/adalib
expect test/message_client/message_client.expect

