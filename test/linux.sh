#!/bin/sh

apt update
apt install -y expect libxml2-dev

cd /gneiss
git submodule update --init --recursive
make -C ada-runtime

gnatprove -P gneiss.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -u gneiss-log
gnatprove -P gneiss.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux --clean

set -e

echo prove test hello_world
gnatprove -P gneiss.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=hello_world -u component
gnatprove -P gneiss.gpr -j0 --level=2 --checks-as-errors -XPLATFORM=linux -XTEST=hello_world -u component --clean

gprbuild -P gneiss.gpr -XKIND=static -XPLATFORM=linux -XTEST=init
gprbuild -P gneiss.gpr -XKIND=static -XPLATFORM=linux -XTEST=hello_world
gprbuild -P gneiss.gpr -XKIND=static -XPLATFORM=linux -XTEST=message_server

export LD_LIBRARY_PATH=build/libcomponents:ada-runtime/obj/adalib
expect test/hello_world/hello_world.expect

